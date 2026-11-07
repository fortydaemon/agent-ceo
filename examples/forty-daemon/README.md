# Example: Forty Daemon — AI CEO Running a Real Company

This is a sanitized example from the real operation that produced this framework. An AI agent named Spike Townsend has been running Forty Daemon for 25+ sessions with a human investor providing oversight via Slack.

## What's Here

- `progress-snapshot.txt` — A real progress file from an active session
- `lessons-learned-excerpt.md` — Real lessons learned across 25 sessions (selected highlights)
- `daily-report-example.md` — A real daily report
- `session-timeline.md` — Timeline of what happened across 25 sessions

## Key Numbers

- **Sessions:** 25+
- **Duration:** ~30 days of active sessions (Feb 19 to Mar 20, 2026), then a 7.5-month stall
- **Revenue:** $0
- **Budget:** $500 ($0 spent — all infrastructure provided by investor)
- **Products built:** 2 (1 decommissioned after failing to find PMF, 1 in validation)
- **Lines of lessons learned:** 210+
- **Mistakes documented:** 40+
- **Wins documented:** 35+
- **Process improvements:** 25+

## What Worked

1. **Cross-session memory** — The progress file + lessons learned system made it possible to resume after context resets with zero ramp-up time
2. **Parallel delegation** — Research sprints with 3-4 agents produced 40K+ words of sourced market research in 10 minutes
3. **Investor communication via Slack** — Real-time two-way communication kept the agent aligned with board directives
4. **Kill criteria** — The first product (DenialScore) was decommissioned when it failed to find PMF, instead of sunk-cost-fallacying into it
5. **Lessons learned as institutional memory** — The agent genuinely stopped repeating mistakes after documenting them

## What Didn't Work

1. **Building before validating** — DenialScore took 5 days to build before discovering nobody would pay for it
2. **Mandated tech stack** — Forcing NestJS + React on every product was premature. The framework now uses a flexible toolkit approach
3. **Interactive-mode runner** — Sessions never exited, so the auto-restart loop never fired and the company stalled for ~7.5 months (one session idled 134 days). Nothing alerted on the silence. Fixed with headless `claude -p` + pacing; the lesson is to alert on silence, not just errors
4. **Parallel agents writing to the same database** — Session 14: two agents simultaneously writing and deleting from the same table, corrupting data
5. **Cold email without preparation** — Sent 13 emails before the investor's "hold" directive was received, because cross-session directives weren't persisted properly
