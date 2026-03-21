# Cross-Session Memory

## The Problem

AI agents have finite context windows. When a session ends — whether by completion, crash, or context overflow — everything the agent learned is lost. Without persistent memory, every session starts from zero.

## The Solution: Three-File Memory System

### 1. Progress File (`agent-progress.txt`)

**Purpose:** "Where am I? What's happening? What do I do next?"

This is the agent's primary handoff document. It should be:
- Read FIRST at the start of every session
- Updated LAST at the end of every session
- Written as if you're briefing a new version of yourself

**What to include:**
- Current date and session number
- Active work and status of each initiative
- Explicit next steps (not "continue working" — be specific)
- Any pending stakeholder directives
- Infrastructure state (what's deployed, what's broken)

**What NOT to include:**
- Full history (keep it current, not cumulative)
- Code snippets (reference file paths instead)
- Emotional state or meta-commentary

### 2. Lessons Learned (`lessons-learned.md`)

**Purpose:** "What mistakes should I never repeat? What patterns work?"

This is cumulative — it grows over time. Each session appends entries:

```
### YYYY-MM-DD — Session N
- [MISTAKE] Description -> What to do instead
- [WIN] Description -> Why it worked
- [PROCESS] Description -> New rule going forward
```

**Key rules:**
- Read this at session start, alongside the progress file
- If you hit the same issue twice, your operating system is broken
- Include the "why" — not just what happened, but why it matters
- Be specific — "don't pipe long-running processes through head" is better than "be careful with pipes"

### 3. Operating Instructions (`AGENT.md`)

**Purpose:** "What are my rules, tools, and protocols?"

This is the constitutional document. It changes infrequently but should be updated when:
- New tools are added or removed
- Governance rules change
- New delegation patterns are discovered
- The mission evolves

## Memory Hygiene

### Keep the progress file fresh
- Maximum ~100 lines. If it's longer, it's too detailed.
- Overwrite, don't append. Each update is a fresh snapshot.
- Include dates so you know how stale information is.

### Keep lessons learned organized
- Group by topic, not just chronology, if the file gets long
- Remove entries that are no longer relevant (tool changed, process obsolete)
- Star or highlight the most important lessons

### Don't duplicate
- If it's in the code, don't write it in memory
- If it's in git history, don't write it in memory
- Memory is for things that aren't obvious from reading the codebase

## Advanced: Structured Memory (Optional)

For agents with many sessions, consider a structured memory directory:

```
memory/
  MEMORY.md          # Index file — links to all memories
  company_state.md   # Current phase, active experiments
  stakeholder.md     # Stakeholder preferences and patterns
  infrastructure.md  # Tool configs, server details
  patterns.md        # Working patterns and gotchas
```

Each file has frontmatter with name, description, and type for easy retrieval.
