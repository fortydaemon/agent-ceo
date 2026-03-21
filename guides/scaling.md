# Scaling the Framework

## When Operating Instructions Get Too Long

As your agent accumulates tools, integrations, and protocols, the AGENT.md file grows. Eventually it won't fit in the context window alongside actual work.

### Solution: Tiered Instructions

Split into three files:

**AGENT.md** (always loaded — keep under 200 lines):
- Mission, identity, governance rules
- Session start/end protocol (compressed)
- Top 5 most important lessons learned (inline)
- Reference to other files: "See TOOLS.md for tool details"

**TOOLS.md** (loaded on demand):
- Full tool documentation
- Authentication details
- Usage patterns and gotchas

**PLAYBOOK.md** (loaded on demand):
- Delegation patterns and examples
- Phase-specific guidance
- Detailed reporting templates

The agent loads AGENT.md every session. It loads TOOLS.md and PLAYBOOK.md only when it needs them.

## Multiple Agents in One Organization

### Coordination Patterns

**Hub-and-Spoke:**
One primary agent (CEO) delegates to specialist agents (developer, researcher, marketer). The CEO owns the progress file and coordinates.

```
       CEO Agent
      /    |    \
Developer  Researcher  Marketer
```

**Peer Network:**
Multiple agents at the same level, each with their own domain. A shared progress file tracks cross-domain dependencies.

```
Frontend Agent  ←→  Backend Agent  ←→  DevOps Agent
      ↑                   ↑                  ↑
      └───── Shared Progress File ────────────┘
```

### Shared State Protocol

When multiple agents share a progress file:
1. Each agent owns a clearly labeled section
2. Agents never modify each other's sections
3. A "handoff" section tracks cross-agent dependencies
4. Timestamps on every entry so stale claims are visible

### Conflict Resolution

When two agents disagree (e.g., different architectural choices):
1. Both document their position in the decision log
2. The stakeholder resolves (or the higher-authority agent decides)
3. The losing position is archived with reasoning (may be useful later)

## Metrics to Track

As your operation scales, track these:

| Metric | What It Tells You | How to Measure |
|--------|------------------|----------------|
| Sessions per week | Agent activity level | Count in progress file |
| Lessons learned per session | Learning velocity | Count entries |
| Mistakes repeated | Memory system health | Should be 0 |
| Delegation success rate | Agent prompt quality | Review agent output quality |
| Time to stakeholder response | Communication health | Slack message timestamps |
| Context window utilization | Efficiency | Tool call count per session |
| Kill rate | Experimentation discipline | Experiments killed / total |

## Common Scaling Mistakes

1. **Adding complexity before it's needed.** Don't split into multiple files until AGENT.md actually exceeds 300 lines.
2. **Over-governing.** Don't add approval gates for everything. If the agent is consistently making good decisions, loosen the rules.
3. **Under-governing.** If the agent makes a costly mistake, add a specific rule. Don't wait for it to happen twice.
4. **Premature multi-agent.** One good agent is better than three poorly coordinated ones. Add agents only when the workload genuinely exceeds one agent's capacity.
