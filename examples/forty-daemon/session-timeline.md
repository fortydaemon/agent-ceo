# Session Timeline — Forty Daemon

A real timeline of an AI agent running a company across 25+ sessions.

## Phase 1: Research Sprint (Sessions 1-3, Day 1)

**Session 1:** Market research. Spawned 4 parallel research agents. Investor redirected from consumer products to B2B to agents to health tech. Each pivot narrowed the focus. Ended with health tech + agent verification as the direction.

**Session 2:** Deep-dive on health tech opportunity. Investor wanted "game changing" not "single feature." Discovered the Honey scandal timing window. Pivoted from consumer trust tools to B2B denial prediction.

**Session 3:** Investor introduced the "data moat" concept. Fundamental reframe: not a SaaS tool company, but a data intelligence company. Key insight: analyze public payer POLICIES instead of patient RECORDS to avoid HIPAA entirely.

## Phase 2: Build Sprint (Sessions 4-12, Days 2-3)

**Session 4:** Built the data pipeline on GPU hardware. CMS NCCI data — 5.4M records loaded. First scraper worked on first try because the data was well-structured (always start with the easiest source).

**Sessions 5-8:** Deployed API to Railway. Built frontend. Added 5 payer data sources (CMS, UHC, Cigna, BCBS, Kaiser). Multiple scrapers running in parallel.

**Session 9:** Frontend + scoring engine working end-to-end. Investor said "you need tests" — spawned 4 agents, 226 tests in 4 minutes.

**Sessions 10-12:** Design system, authentication, blog, error monitoring. **CRITICAL MISTAKE in Session 12:** Sent 13 cold emails without checking Slack for investor's "hold" directive. Led to new rule: all directives must be in progress file.

## Phase 3: Productionization (Sessions 13-18, Days 3-4)

**Session 14: WORST SESSION.** Three background agents fighting over the same database table. One deleting, one importing, one piping from remote. Hours of wasted work, corrupted data. Led to rule: never have multiple agents writing to the same resource.

**Session 18:** 226 tests, Storybook design system, premium UI overhaul. The most productive build session. Key: clear delegation with specific acceptance criteria.

## Phase 4: Pipeline & Intelligence (Sessions 19-24, Days 5-30)

**Sessions 19-21:** Market intelligence pipeline on GPU hardware. 7 scrapers, LLM scoring, cron automation. Ran autonomously for 7 days collecting 8,619 signals.

**Session 22:** Health tech AgentOps deep-dive. Pitched verification layer concept to investor. Response: "dig deeper on the verification layer" — engagement signal.

**Session 24:** Investor directive: tear down the pipeline and decommission everything. Clean slate. The agent complied without argument — investor directives are board directives.

## Phase 5: Strategic Reset (Session 25, Day 30)

**Session 25:** Investor asked "what should we be building in the agentic world?" Rewrote entire operating model. Shifted from SaaS to rapid experimentation. Three new experiments launched. Open-sourced the framework itself.

## Key Metrics Across All Sessions

| Metric | Value |
|--------|-------|
| Total sessions | 25+ |
| Products built | 2 |
| Products killed | 1 (DenialScore — failed PMF) |
| Data records processed | 5.4M+ |
| Tests written | 226 |
| Budget spent | $0 of $500 |
| Critical mistakes | 3 (cold email, DB corruption, missed directive) |
| Revenue | $0 |
| Mistakes repeated | 3 (storage limit x3, uncleared cold email x2, concurrent DB writers x2); repeats stopped once lessons became hard RULEs |
| Research reports generated | 8 (~20-50K words each) |

## Lessons That Shaped the Framework

1. **Memory is everything** — Without the progress file, every session would start from zero. This single pattern is the most valuable piece of the framework.
2. **Delegation works when specific** — "Write tests" fails. "Write tests for this file, mock these deps, cover these edge cases" produces excellent results.
3. **Kill fast** — DenialScore took 5 days to build. The next experiment took 1 day to validate. Faster experiments = faster learning.
4. **Stakeholder directives are sacred** — Missing the "hold" directive cost trust. Now all directives are persisted immediately.
5. **Parallel agents are powerful but dangerous** — Without resource locking, they can destroy each other's work.

## Phase 6: The Stall (2026-03-21 to 2026-11-06)

No sessions ran for about 7.5 months. The runner launched Claude Code in interactive mode, so a finished session waited at the prompt forever and the respawn loop never fired. One session idled for 134 days. Fixed by running headless (`claude -p`) with a 4-hour pacing gap; see `scripts/run-agent.sh`.
