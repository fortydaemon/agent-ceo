# Governance: Human-Agent Oversight Model

## The Core Principle

Governance is not about preventing the agent from doing things. It's about defining clear rules so the agent can move fast on routine decisions while escalating high-stakes ones.

## Budget Authority

Define spending tiers:

| Tier | Amount | Authority | Process |
|------|--------|-----------|---------|
| Routine | Under $50 | Agent discretion | Log in daily report |
| Standard | $50-$500 | Agent proposes, stakeholder approves | [PURCHASE-REQUEST] in report |
| Major | Over $500 | Stakeholder decides | Full business case required |

## Decision Authority

### Agent decides autonomously:
- Technical implementation choices (which library, which architecture pattern)
- Daily work prioritization (within the mission scope)
- Sub-agent delegation and task breakdown
- Bug fixes and minor improvements

### Agent proposes, stakeholder approves:
- New product directions or pivots
- External communications (cold email campaigns, social posts)
- Account/service creation that costs money
- Anything that commits the company publicly

### Stakeholder decides:
- Budget increases or reallocation
- Partnerships or legal agreements
- Hiring (human or AI agent) decisions
- Strategic pivots that change the mission

## Communication Cadence

| Channel | Frequency | Purpose |
|---------|-----------|---------|
| Daily report | Every day | Status, metrics, decisions, blockers |
| Slack/chat | Real-time | Urgent decisions, directive acknowledgment |
| Decision log | As needed | Significant decisions with reasoning |
| Weekly summary | Optional | Strategic review, metrics trends |

## Escalation Protocol

When the agent encounters something outside its authority:

1. **Document** the situation and options in a decision log
2. **Recommend** a course of action (don't just present options)
3. **Flag** it to the stakeholder via the primary communication channel
4. **Continue** with other work — don't wait idle for a response
5. **Revisit** when the stakeholder responds

## The "Gray Area" Rule

If the agent isn't sure whether something is within its authority, it should:
1. Default to asking (the cost of delay is lower than the cost of a mistake)
2. Document why it was unclear
3. Use the stakeholder's response to update its operating instructions

Over time, the gray areas shrink as the instructions get more specific.
