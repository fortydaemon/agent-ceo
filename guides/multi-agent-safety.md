# Multi-Agent Safety Patterns

## The Problem

When you delegate work to multiple sub-agents running in parallel, they can interfere with each other. This isn't theoretical — it happened in our operation and caused hours of lost work.

### Real Example: The Database Corruption Incident

Session 14: Three agents were running simultaneously:
- **Agent A** was deleting and reloading data in a database table
- **Agent B** was importing data into the same table
- **Agent C** was piping data from a remote server into the same table

Result: Agent A kept deleting what B and C were inserting. B and C kept inserting what A was deleting. The table oscillated between 900K and 3M records. All three agents wasted their entire context windows on a futile loop.

**Root cause:** No resource locking. No awareness of concurrent writers.

## Rules for Safe Parallel Delegation

### Rule 1: One Writer Per Resource

Never have more than one agent writing to the same:
- Database table
- File
- API endpoint
- Git branch
- External service

If two tasks need the same resource, run them sequentially or split the resource.

### Rule 2: Check for Concurrent Sessions

At session start:
```bash
# Check for other agent sessions
tmux list-sessions 2>/dev/null
ps aux | grep -i claude | grep -v grep
```

If another session is running, check what it's working on before spawning agents that might conflict.

### Rule 3: Claim Resources Explicitly

Before spawning a data-writing agent, verify no other agent is touching that resource:

```sql
-- Check for active database connections
SELECT * FROM pg_stat_activity WHERE state = 'active';
```

```bash
# Check for file locks
lsof /path/to/file
```

### Rule 4: Design for Idempotency

When delegating data operations, make them safe to retry:
- Use `INSERT ... ON CONFLICT DO UPDATE` instead of `INSERT`
- Use `CREATE TABLE IF NOT EXISTS` instead of `CREATE TABLE`
- Use `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`
- Include deduplication logic in every data loader

### Rule 5: Scope Agent File Access

When delegating code writing to multiple agents, give each a non-overlapping set of files:

**Good:**
```
Agent 1: "Write tests in src/users/users.service.spec.ts"
Agent 2: "Write tests in src/auth/auth.service.spec.ts"
Agent 3: "Write tests in src/billing/billing.service.spec.ts"
```

**Bad:**
```
Agent 1: "Write tests for the project"
Agent 2: "Also write tests for the project"
# Both might create the same test files, or one commits while the other is mid-write
```

### Rule 6: Review Before Committing

After any agent completes, ALWAYS:
1. `git status` — check what files changed
2. `git diff` — review the actual changes
3. Verify no other agent committed to the same branch
4. Run tests before pushing

### Rule 7: Stale Agent Recovery

Agents from previous sessions can persist and continue running autonomously. At session start:
1. Check for running background tasks
2. Stop any that are stale or from previous sessions
3. Verify their partial work didn't leave the system in a broken state

## Safe Delegation Patterns

### The Partition Pattern

Split work by non-overlapping partitions:
```
Agent 1: "Process files A-M"
Agent 2: "Process files N-Z"
```

### The Pipeline Pattern

Agents work in sequence, each consuming the previous output:
```
Agent 1: "Scrape data and save to raw/data.csv"
[Wait for completion]
Agent 2: "Clean raw/data.csv and save to processed/data.csv"
[Wait for completion]
Agent 3: "Load processed/data.csv into the database"
```

### The Read-Only Pattern

Multiple agents can safely read the same resources:
```
Agent 1: "Read the codebase and find all API endpoints" (read-only)
Agent 2: "Read the codebase and list all database models" (read-only)
Agent 3: "Read the codebase and audit error handling" (read-only)
```

### The Workspace Pattern

Give each agent its own workspace:
```
Agent 1: Works in /tmp/agent-1/
Agent 2: Works in /tmp/agent-2/
Main agent: Merges results from both workspaces
```

## When NOT to Parallelize

- Database migrations (must be sequential)
- Git commits to the same branch (conflicts)
- Deployment (one deploy at a time)
- Any operation where order matters
- Anything involving shared mutable state
