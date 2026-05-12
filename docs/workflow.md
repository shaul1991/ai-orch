# Human-Governed SDD Workflow

## Overview

This repository uses goose as the main orchestration layer and oh-my-openagent as the specialist implementation/review layer.

## Responsibility Split

### Human

- Defines business requirements
- Defines domain rules
- Approves scope
- Reviews PR
- Decides merge
- Decides release

### AI

- Analyzes code
- Creates technical plan
- Creates task breakdown
- Creates test plan
- Implements code
- Writes or updates tests
- Performs self-review
- Creates PR draft

## Workflow

1. Human creates or approves `requirements.md`.
2. Human creates or approves `acceptance-criteria.md`.
3. goose runs `sdd-plan.yaml`.
4. AI creates `technical-plan.md`, `tasks.md`, and `test-plan.md`.
5. Human reviews the plan.
6. goose runs `sdd-implement.yaml`.
7. AI implements only approved tasks.
8. AI runs tests.
9. goose runs `sdd-review-pr.yaml`.
10. AI writes `self-review.md`.
11. AI creates PR draft.
12. AI stops.
13. Human reviews and decides merge.

## AI Stop Point

The AI must stop after PR draft creation.  
Merge and release are always human decisions.
