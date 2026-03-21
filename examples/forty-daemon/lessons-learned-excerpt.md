# Lessons Learned — Forty Daemon (Selected Highlights)

These are real entries from 25+ sessions of an AI agent running a company.

## Delegation

- [WIN] Spawning 4 parallel research agents immediately was highly effective. All 4 completed detailed reports (~30KB each) while I did strategic synthesis. This is the right pattern for research sprints.
- [WIN] Delegating test writing to 4 parallel agents produced 226 tests in ~4 minutes of wall time. The key: give each agent exact file paths, specific test cases with expected values, and mock patterns.
- [CRITICAL MISTAKE] Multiple background agents fighting over the same database table. Agent A was DELETING data while Agent B was IMPORTING it. Result: hours of wasted work and corrupted data. -> RULE: NEVER have more than one agent writing to the same resource. Check for concurrent writers before spawning data agents.
- [MISTAKE] Stale agents from previous sessions persisted and ran autonomously, making destructive changes. -> RULE: At session start, check for running background tasks and stop any that are stale.

## Stakeholder Communication

- [CRITICAL MISTAKE] Sent 13 cold emails without checking for Investor's "hold" directive in Slack. A parallel session had committed to holding outreach pending approval. Root cause: cross-session directives were only in Slack, not in progress file. -> RULE: All stakeholder directives MUST be written to progress file immediately.
- [WIN] Breaking a long pitch into 4 Slack messages (problem -> architecture -> insight -> business model) was well-received. Structure long pitches as a narrative arc, not a wall of text.
- [PROCESS] When stakeholder asks "how would this work?" — go mechanical and specific. Not "AI agents could help" but "the receipt shows Policy 2024T0194 Section 3.2, 4/4 criteria matched, confidence 94%, one-click approve."
- [PROCESS] Lead with a clear recommendation, not a menu of options. The stakeholder wants a decision, not homework.

## Memory & State Management

- [WIN] Properly saving progress file before context overflow enabled clean continuation in the next session. Always save state before context overflow.
- [MISTAKE] Memory file had wrong database credentials. -> Always verify credentials against actual config files, not from memory records.
- [PROCESS] All investor/stakeholder directives MUST be written to progress file immediately, not just acknowledged in chat. Future sessions must see them.

## Product & Strategy

- [MISTAKE] First pitch was a single-feature product. Investor wanted "game changing." -> Think bigger. Combine related problems into a platform play.
- [WIN] The disruption-play framework (find proven markets with bad tools) yielded much stronger results than greenfield research. Look for broken incumbents, not gaps.
- [WIN] Discovering a timing window (Honey scandal) was the breakthrough. Real-time market events create urgency that abstract TAM analysis doesn't. Always look for acute timing triggers.
- [PROCESS] When the stakeholder redirects strategy, don't just adjust the product — re-examine the entire business model.
- [PROCESS] When stakeholder rejects a pitch, don't tweak — re-examine the entire framework. The issue was the research methodology, not the specific product.

## Infrastructure

- [MISTAKE] Never pipe long-running processes through head/tail — causes SIGPIPE and kills the process. Use run_in_background parameter instead.
- [MISTAKE] Railway 500MB PostgreSQL volume fills fast. Always calculate storage impact BEFORE loading data, not after.
- [WIN] Docker containers on edge hardware (Orin) are the right call — the host has Python 3.8 with no pip. Don't fight the OS, use containers.
- [PROCESS] For cloud database bulk loads: use BATCH_SIZE=1000 (not 5000) and pool_pre_ping=True. Larger batches cause SSL connection drops.

## Context Window Management

- [PROCESS] 9 parallel agents + CEO research across 3 research sprints in one session is sustainable but approaching context limits. Start winding down after 50+ tool calls.
- [PROCESS] If you catch yourself writing boilerplate code past the halfway point of a session, STOP. Spawn an agent.
- [WIN] Ending sessions cleanly with full progress file updates made the next session's ramp-up near-zero. The progress file IS the institutional memory.
