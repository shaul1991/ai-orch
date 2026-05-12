# Human-Governed SDD AI Orchestration Template

This repository contains a reusable Human-Governed Spec-Driven Development template for AI-assisted software work.

## Core Idea

Human owns domain and business decisions. AI owns technical planning, implementation, testing, self-review, and PR draft creation within approved scope.

## Main Components

- `AGENTS.md`: repository-level AI agent rules
- `docs/ai-governance.md`: authority boundaries and hard rules
- `docs/workflow.md`: SDD workflow from requirements to PR draft
- `docs/specs/sample-feature/`: sample SDD artifact templates
- `.goose/recipes/`: goose workflow recipes
- `.opencode/`: oh-my-openagent/OpenCode configuration and skills
- `scripts/`: guard, test, and PR draft helper scripts

## Quick Check

```bash
scripts/check-sdd-docs.sh sample-feature
scripts/run-tests.sh
```
