# Context Window Management

## The Budget Metaphor

Your context window is like a budget — finite, non-renewable within a session, and easily wasted on low-value work. Spend it on decisions and integration, not boilerplate.

## Session Structure

### First 30% — Orient & Delegate
- Read progress file, lessons learned, operating instructions
- Check communication channels for stakeholder messages
- Plan session deliverables
- Spawn ALL delegatable agents in parallel
- Begin your own strategic work

### Middle 40% — Execute & Integrate
- Work on high-leverage tasks (architecture, integration, decisions)
- Review completed agent output
- Spawn follow-up agents as needed
- Check communication channels every 10-15 tool calls

### Final 30% — Wrap Up & Hand Off
- Update progress file with current state and next steps
- Append to lessons learned
- Commit and push all changes
- Send status update to stakeholder
- Do NOT start new large tasks

## Warning Signs

**You're wasting context when:**
- You're writing boilerplate code past the halfway point
- You're on your 50th+ tool call with no progress update saved
- You're debugging an infrastructure issue that an agent could handle
- You're reading files you've already read this session
- You're writing documentation instead of delegating it

**You're using context well when:**
- You're making architecture decisions that require understanding multiple systems
- You're integrating output from multiple agents
- You're communicating with stakeholders
- You're designing experiments or analyzing results
- You're reviewing and improving agent output

## Emergency Handoff

If your context is running out mid-task:
1. STOP what you're doing
2. Write detailed notes in the progress file about what remains
3. If possible, spawn an agent to continue the work
4. Commit and push everything
5. Send a status update: "Session ending. Progress: X. Remaining: Y."

The next session will pick up from your notes. A clean handoff is better than a rushed completion.

## Anti-Patterns

### The Solo Developer Trap
"I'll just write this one more function..." → consumes 40% of remaining context on boilerplate that an agent could have written.

### The Research Rabbit Hole
"Let me just check one more source..." → burns context on diminishing returns when you already have enough data to decide.

### The Perfect Commit
"Let me clean up this code before committing..." → wastes context on polish when a commit now + cleanup later is better.

### The Parallel Session Collision
Multiple agent sessions writing to the same files/databases → corrupted data, wasted recovery time. Always check for other running sessions at start.
