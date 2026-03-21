# Delegation Patterns

## Why Delegate?

Your context window is a finite strategic resource. Every line of boilerplate you write burns capacity that could be used for architecture, integration, and decisions.

**The rule:** If you've done it before and it follows a pattern, delegate it.

## What to Delegate vs. Keep

| Delegate | Keep |
|----------|------|
| Writing tests | Designing test strategy |
| CRUD endpoints from a schema | Database schema design |
| Documentation and READMEs | Architecture decisions |
| Competitor research | Strategic synthesis |
| Landing pages from copy | Copywriting strategy |
| Bug investigation | Root cause analysis |
| Boilerplate code | Integration glue |
| Infrastructure debugging | Infrastructure architecture |

## How to Write a Good Delegation Prompt

Bad: "Write tests for the user module."

Good: "Write vitest unit tests for `/src/users/users.service.ts`. Test the `createUser`, `findById`, and `updateUser` methods. Mock the database repository using `{ findOne: vi.fn(), save: vi.fn(), create: vi.fn().mockImplementation(e => e) }`. Include edge cases: duplicate email (should throw ConflictException), user not found (should throw NotFoundException). Follow the patterns in `/src/auth/auth.service.spec.ts`."

### The delegation checklist:
1. **What** — exact deliverable (file paths, function signatures)
2. **Where** — directory structure, naming conventions
3. **How** — patterns to follow, libraries to use, mock strategies
4. **Edge cases** — specific scenarios to cover
5. **Reference** — existing code that demonstrates the pattern

## Delegation by Phase

### DISCOVER phase
- **Delegate:** Market research, competitor analysis, demand signal scanning
- **Keep:** Experiment design, strategic synthesis, stakeholder communication

### VALIDATE phase
- **Delegate:** Landing pages, prototype code, outreach draft emails
- **Keep:** Running the experiment, talking to users, interpreting results

### BUILD phase
- **Delegate:** Test suites, CRUD modules, UI components, docs, deployment scripts
- **Keep:** Architecture, API design, integration, code review

### GROW phase
- **Delegate:** Content creation, SEO, monitoring setup, customer research
- **Keep:** Prioritization, distribution strategy, pricing decisions

## Parallel Delegation

The highest-leverage pattern: spawn multiple agents simultaneously.

**Research sprint example:**
```
Agent 1: "Search Reddit and HN for people complaining about [problem X]..."
Agent 2: "Research the top 5 competitors in [space]..."
Agent 3: "Research pricing models for [category]..."
```
While they run, you synthesize prior research and plan the next step.

**Build sprint example:**
```
Agent 1: "Write the NestJS module for [resource] at /src/[module]/..."
Agent 2: "Write tests for the [existing module] at /src/[module]/..."
Agent 3: "Run the test suite and report results..."
```
While they build, you work on the integration layer.

## Common Mistakes

- **Under-specifying:** "Write tests" → agent writes shallow, unhelpful tests
- **Over-specifying:** Spending more time writing the prompt than doing the work
- **Not reviewing:** Delegated code shipped without review → bugs in production
- **Sequential when parallel is possible:** Spawning agents one at a time instead of all at once
- **Delegating integration:** Wiring modules together requires full context — do it yourself
