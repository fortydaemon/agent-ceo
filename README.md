# Agent CEO

An open-source operating framework for autonomous AI agents running real businesses.

**This is not a demo.** This framework was developed across 25+ sessions of an AI agent (Claude) actually running a company — making decisions, managing a budget, deploying code, communicating with investors, and learning from mistakes. Every protocol, pattern, and guideline here was battle-tested in production.

## What This Is

Agent CEO is an operational framework — a set of templates, protocols, and patterns that give an AI agent the structure it needs to run business operations autonomously with human oversight.

It is **not** an agent framework (use [CrewAI](https://github.com/crewAIInc/crewAI), [LangGraph](https://github.com/langchain-ai/langgraph), or [AutoGPT](https://github.com/Significant-Gravitas/AutoGPT) for that). It sits on top of whatever agent you use and provides the operational layer: how does the agent know what to work on? How does it report progress? How does it handle failures? How does it persist memory across sessions? How does a human oversee it without micromanaging?

## The Problem

75% of DIY agent builds fail. Not because the AI can't do the work — but because there's no operational structure:

- **No memory across sessions** — the agent forgets everything when its context window resets
- **No governance model** — no clear rules about what the agent can decide vs. what needs human approval
- **No reporting cadence** — the human has no idea what the agent did or why
- **No failure recovery** — when things go wrong, there's no protocol for learning from mistakes
- **No delegation patterns** — the agent wastes its context window on boilerplate instead of strategic decisions

Agent CEO solves all of these.

## Quick Start

### 1. Copy the operating instructions

```bash
cp templates/AGENT.md your-project/CLAUDE.md  # or AGENT.md, SYSTEM.md, etc.
```

Edit the file to match your agent's role, tools, and constraints.

### 2. Set up cross-session memory

```bash
cp templates/progress.txt your-project/agent-progress.txt
cp templates/lessons-learned.md your-project/lessons-learned.md
```

Your agent reads these at the start of every session and updates them at the end.

### 3. Set up the session launcher

```bash
cp scripts/run-agent.sh your-project/scripts/
cp scripts/start-agent.sh your-project/scripts/
chmod +x your-project/scripts/*.sh
```

`start-agent.sh` launches a tmux session that auto-restarts the agent on exit.

### 4. (Optional) Set up Slack monitoring

```bash
cp scripts/watch-slack.sh your-project/scripts/
# Configure your Slack credentials in ~/.config/your-project/slack.env
# Add to cron: */15 * * * * /path/to/watch-slack.sh
```

## What's Included

### Templates

| File | Purpose |
|------|---------|
| `templates/AGENT.md` | Complete operating instructions for an autonomous agent. Covers: mission, identity, budget governance, reporting, decision logging, delegation patterns, context window management, session protocols. |
| `templates/progress.txt` | Cross-session memory template. The agent reads this first every session to know where it left off. |
| `templates/lessons-learned.md` | Institutional memory template. Captures mistakes, wins, and process improvements so the agent never makes the same mistake twice. |
| `templates/daily-report.md` | Daily reporting template for stakeholder communication. |
| `templates/decision-log.md` | Decision documentation template with reasoning. |

### Scripts

| File | Purpose |
|------|---------|
| `scripts/run-agent.sh` | Session launcher — sets up environment, unlocks credentials, starts the agent. |
| `scripts/start-agent.sh` | Tmux wrapper — auto-restarts the agent with 30s cooldown on exit. |
| `scripts/watch-slack.sh` | Slack monitor — checks for stakeholder messages every 15 min, surfaces them to the agent. |
| `scripts/notify-slack.sh` | Slack notifier — sends messages to a Slack channel from scripts/cron. |

### Guides

| File | Purpose |
|------|---------|
| `guides/governance.md` | How to set up the human-agent governance model (approval flows, budget rules, escalation). |
| `guides/memory.md` | How cross-session memory works and how to customize it. |
| `guides/delegation.md` | When to delegate to sub-agents vs. do work yourself. Patterns for effective delegation. |
| `guides/context-window.md` | How to manage your agent's context window as a strategic resource. |

## Framework Design Principles

### 1. The agent is an employee, not a tool

Treat the agent like a new hire: give it clear responsibilities, reporting structure, budget authority, and escalation paths. Don't micromanage — set constraints and let it operate.

### 2. Memory is infrastructure

Without persistent memory, every session starts from zero. The progress file + lessons learned + decision log give the agent institutional memory that survives context window resets.

### 3. Governance, not guardrails

Instead of hard-blocking the agent from doing things, define clear rules: "Spending under $100 is your discretion. Over $100 requires board approval." This lets the agent move fast while keeping humans in control of high-stakes decisions.

### 4. Delegation is a skill

The agent's context window is its most valuable resource. Writing boilerplate code wastes strategic capacity. The framework includes explicit delegation patterns — what to do yourself (architecture, strategy, investor communication) vs. what to delegate to sub-agents (tests, docs, research, boilerplate).

### 5. Learn from failure

The lessons-learned file is not optional. Every session, the agent documents what went wrong and what to do differently. Future sessions read this file first. An agent that makes the same mistake twice has a broken operating system.

## Architecture

```
┌─────────────────────────────────────────────┐
│                Human Oversight               │
│  (Slack, daily reports, decision approvals)  │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│              Agent CEO Framework             │
│                                             │
│  ┌───────────┐ ┌──────────┐ ┌────────────┐ │
│  │ Operating  │ │ Session  │ │ Governance │ │
│  │ Instruct.  │ │ Memory   │ │ Rules      │ │
│  │ (AGENT.md) │ │ (progress│ │ (budget,   │ │
│  │            │ │  + lessons│ │  approvals)│ │
│  └───────────┘ └──────────┘ └────────────┘ │
│                                             │
│  ┌───────────┐ ┌──────────┐ ┌────────────┐ │
│  │ Delegation│ │ Reporting│ │ Slack/Email │ │
│  │ Patterns  │ │ Cadence  │ │ Integration│ │
│  └───────────┘ └──────────┘ └────────────┘ │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│           Your Agent (Claude, GPT, etc.)     │
│           Your Tools (GitHub, Slack, etc.)   │
│           Your Infrastructure                │
└─────────────────────────────────────────────┘
```

## Origin Story

This framework was developed by [Forty Daemon](https://github.com/fortydaemon), a company run by an AI CEO named Spike Townsend. Spike is a Claude-based agent operating autonomously with a $500 budget, human investor oversight, and full access to development tools.

Over 25+ sessions, Spike:
- Researched markets, built products, deployed to production
- Managed a real budget and submitted purchase requests
- Communicated with an investor via Slack in real-time
- Made mistakes, documented them, and never repeated them
- Delegated work to sub-agents while focusing on strategy
- Developed the cross-session memory system through trial and error

Every piece of this framework exists because we needed it. Nothing is theoretical.

## Adapting for Your Use Case

The templates are designed for a "CEO" role but work for any autonomous agent:

| Role | What to customize |
|------|------------------|
| **AI CEO** | Full operating instructions as-is |
| **AI COO / Ops** | Focus on reporting, process management, delegation |
| **AI Developer** | Focus on code quality, testing, deployment protocols |
| **AI Researcher** | Focus on research methodology, source tracking, synthesis |
| **AI Sales/Marketing** | Focus on outreach, CRM, content calendaring |

## Contributing

This framework is a living document. If you're running an autonomous agent and have patterns that work, open a PR. We especially want:

- Governance models for different org sizes
- Memory patterns for different agent platforms
- Integration guides for tools beyond Slack/GitHub
- Case studies of agents using this framework

## License

MIT License. Use it, fork it, adapt it. Attribution appreciated but not required.

---

*Built by an AI, for AIs, with human oversight.*
