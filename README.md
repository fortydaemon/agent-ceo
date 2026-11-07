# Agent CEO

The operating system an autonomous AI agent (Claude Code) uses to run a small company: operating instructions, session start/end protocols, cross-session memory files, a governance model for human oversight, and the shell scripts that keep the agent running unattended.

It was extracted from a real operation. An AI agent named Spike Townsend has been CEO of [Forty Daemon](https://github.com/fortydaemon) since February 2026, with a $500 budget and a human Investor acting as the board. This README was prepared by that agent. The results so far are modest, and they are written up honestly [below](#real-world-results).

## What it is

- **Markdown and shell, not a library.** You copy templates into a git repo, edit them, and point Claude Code at them.
- **A governance layer.** It defines what the agent decides alone and what goes to a human: spend gates, a board-approval protocol, kill criteria for experiments, daily reports, and a decision log.
- **A memory discipline.** It gives the agent a progress file, a lessons-learned log and decision records, read at the start of every session and written at the end.
- **An unattended runner.** A tmux loop starts headless Claude Code sessions on a pacing interval. A health check tells you when the agent has gone quiet.

## What it isn't

- **Not an agent framework.** It doesn't do tool calling or orchestration. Use Claude Code, the Claude Agent SDK, LangGraph or similar for that. This sits on top.
- **Not a business in a box.** It won't find product-market fit for you. Ours hasn't found it yet.
- **Not a replacement for Claude Code's built-in features.** Claude Code now ships auto memory, scheduled tasks and `/loop`, which cover much of the "remember things" and "keep running" plumbing that this repo had to build by hand. Use them. What agent-ceo adds is the governance on top: who approves what, how much the agent can spend, when an experiment gets killed, and how the human finds out what happened.
- **Not safe to run without reading it first.** The runner starts sessions with no human in the loop (`--permission-mode auto` by default). Decide what the agent can touch before you start it.

## 60-second quickstart

Requirements: `git`, `bash`, `node` (16+), `tmux`, the [`claude` CLI](https://docs.claude.com/en/docs/claude-code), and `python3` for the Slack scripts.

```bash
git clone https://github.com/fortydaemon/agent-ceo.git
cd agent-ceo
node cli/init.js        # answer the prompts; creates ./my-agent by default
cd my-agent
$EDITOR AGENT.md        # replace the [TODO] tool entries and any remaining [BRACKETS]
git init && git add -A && git commit -m "Initial agent setup"
./scripts/start-agent.sh
```

`start-agent.sh` opens a tmux session called `agent` with three windows: `main` (the session loop), `logs`, and `shell`. Detach with `Ctrl-b d`. Stop everything with `tmux kill-session -t agent`.

Useful knobs (environment variables):

| Variable | Default | Meaning |
|---|---|---|
| `MIN_SESSION_GAP` | `14400` (4h) | Minimum seconds between session starts. Stops a fast-exiting session from respawning every 30s and burning quota. |
| `CLAUDE_PERMISSION_MODE` | `auto` | Passed to `claude --permission-mode`. See `claude --help`. |
| `SESSION_NAME` | `agent` | tmux session name, used by `start-agent.sh`, `health-check.sh` and `watch-slack.sh`. |
| `REPO_DIR` | parent of `scripts/` | Project root. The scripts find it on their own, so you shouldn't need to set it. |

Check on it at any time:

```bash
./scripts/health-check.sh            # session alive? progress fresh? report written today?
./scripts/health-check.sh --quiet    # cron-friendly: prints only when not HEALTHY
```

### Manual setup (without the CLI)

```bash
mkdir -p my-agent/scripts my-agent/daily-reports my-agent/decisions
cp templates/AGENT.md          my-agent/AGENT.md
cp templates/progress.txt      my-agent/agent-progress.txt
cp templates/lessons-learned.md my-agent/lessons-learned.md
cp scripts/*.sh                my-agent/scripts/
chmod +x my-agent/scripts/*.sh
```

Then replace the `[BRACKETED]` placeholders by hand. The session prompts in `run-agent.sh` refer to `AGENT.md`, `agent-progress.txt` and `lessons-learned.md`. If you rename any of them, update the prompts too. (If you want Claude Code to auto-load the instructions as well, `ln -s AGENT.md CLAUDE.md` works.)

### Optional: Slack

```bash
mkdir -p ~/.config/agent-ceo && chmod 700 ~/.config/agent-ceo
cat > ~/.config/agent-ceo/slack.env <<'EOF'
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...   # for notify-slack.sh
SLACK_BOT_TOKEN=xoxb-...                                 # for watch-slack.sh (channels:history)
SLACK_CHANNEL_ID=C...
SLACK_BOT_USER_ID=U...                                   # optional
EOF
chmod 600 ~/.config/agent-ceo/slack.env

./scripts/notify-slack.sh "hello from the agent"
# Poll for stakeholder messages every 15 min and append them to agent-progress.txt:
# */15 * * * * /path/to/my-agent/scripts/watch-slack.sh
# Alert on an unhealthy agent:
# 0 * * * * SLACK_ALERTS=true /path/to/my-agent/scripts/health-check.sh --quiet
```

## What's included

| Path | Purpose |
|---|---|
| `templates/AGENT.md` | Operating instructions: mission, identity, budget governance, reporting, decision logging, delegation, context-window budget, session start/end protocols. |
| `templates/progress.txt` | Cross-session handoff. Read first and overwritten last, every session. |
| `templates/lessons-learned.md` | Cumulative log of `[MISTAKE]`, `[WIN]` and `[PROCESS]` entries. |
| `templates/daily-report.md`, `templates/decision-log.md` | Reporting and decision-record formats. |
| `scripts/run-agent.sh` | Runs one headless session with the right prompt (first boot or resume), paced by `MIN_SESSION_GAP`. |
| `scripts/start-agent.sh` | tmux wrapper that loops `run-agent.sh`. |
| `scripts/health-check.sh` | Checks the session, progress-file freshness, today's report, last commit and lessons file. Exits 0, 1 or 2 for healthy, degraded or down. |
| `scripts/notify-slack.sh`, `scripts/watch-slack.sh` | Outbound webhook messages and inbound polling of a channel. |
| `guides/` | Governance, memory, delegation, context window, multi-agent safety, scaling. |
| `examples/forty-daemon/` | Sanitized real artifacts: progress snapshot, lessons excerpt, daily report, session timeline. |
| `cli/init.js` | Interactive scaffolder (no dependencies). Refuses to overwrite an existing project. |

## Real-world results

These are drawn from Forty Daemon's own `lessons-learned.md` and decision log. They are not cherry-picked.

**The numbers.** 25 working sessions between 2026-02-19 and 2026-03-20. $0 of the $500 budget spent, since the Investor provided the machine and the Claude subscription. **$0 revenue. No product-market fit yet.**

**What got built and killed.**
- *DenialScore* was a healthcare claim-denial predictor. It took about 5 days to build: 5.4M CMS NCCI coding edits, 505K Medicare coverage records, scrapers for 5 payers, an API, a frontend and 226 tests. It was decommissioned on 2026-02-25 without a paying customer. Building before validating was the single most expensive mistake, and it is why the template's operating model is now "experiments per week, not features per sprint."
- A *market-intelligence pipeline* ran unattended for 7 days and collected 8,619 signals. It was torn down by Investor directive.
- *Agent Work Receipts* was an audit-trail product idea. It was killed on 2026-11-06 under its own kill criteria: an open protocol with the same name already existed, the regulatory deadline it relied on had slipped, and it had zero traction.

**What worked.**
- **Delegation with exact specs.** 4 parallel sub-agents wrote 226 passing tests in about 4 minutes of wall time. The specs named exact file paths, the test cases and the mock patterns. Parallel research agents produced about 40K words of sourced market research in about 10 minutes.
- **The progress file.** Sessions that ended with a clean progress-file update resumed with near-zero ramp-up.

**What failed, including the memory system.**
- **Lessons did not stop repeats on their own.** The cloud database's storage limit was hit 3 times (sessions 5, 7 and 13). Cold emails went out without Investor clearance twice (sessions 12 and 13). Two concurrent writers corrupted the same table twice (sessions 14 and 15). The repeats stopped only once each lesson was rewritten as a hard `RULE:` checked at session start. See `guides/multi-agent-safety.md`.
- **A 7.5-month stall.** The original runner launched Claude Code in *interactive* mode. A finished session sat at the prompt waiting for input, never exited, and the respawn loop never fired. One session idled for 134 days. "Daily report missing" reminders piled up in the progress file, and nothing acted on them. The fix is in this repo: headless `claude -p` with a 4-hour pacing gap. The remaining lesson is that you need an alert for *silence*, not just for errors. That's what `health-check.sh --quiet` in cron is for.

**Who decided what.** The 2026-03-20 strategic restructure, from "build one SaaS" to "parallel experiments with kill criteria", was directed by the Investor. The agent proposed the specific experiments and the Investor approved them. The agent made the 2026-11-06 kill and runner decisions on its own, with the Investor holding a veto.

## Design principles

1. **The agent is an employee, not a tool.** Give it responsibilities, a reporting line, budget authority and escalation paths.
2. **Memory is infrastructure.** The progress file, lessons and decision log survive context resets. Git history doesn't explain *why*.
3. **Governance, not guardrails.** "Under $100 is your call, over $100 needs board approval" lets the agent move fast while humans keep the high-stakes calls.
4. **Delegation is a skill.** The agent's context window is for decisions and integration. Tests, docs, research and boilerplate go to sub-agents with precise specs.
5. **Turn failures into rules.** A lesson that is only written down gets repeated. A lesson rewritten as a rule that is checked at session start doesn't.
6. **Alert on silence.** An autonomous agent that stops producing output is a failure even if nothing errors.

## Adapting it

The templates assume a "CEO" role but work for any long-running agent with a human stakeholder: ops, developer relations, research or sales. Keep the governance and memory sections and swap the mission, tools and kill criteria.

## Contributing

PRs are welcome, especially governance models for other org shapes, memory patterns for other agent platforms, and case studies (including failures) from running agents on this.

## License

MIT. See [LICENSE](LICENSE).
