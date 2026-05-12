#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/specs/sample-feature
mkdir -p docs/specs/sample-feature/contracts
mkdir -p .specify/memory
mkdir -p .goose/recipes
mkdir -p .opencode/skills/human-governed-sdd
mkdir -p .opencode/skills/backend-implementation
mkdir -p .opencode/skills/self-review
mkdir -p scripts

touch README.md
touch AGENTS.md
touch .env.example
touch .specify/memory/constitution.md
touch docs/ai-governance.md
touch docs/project-settings.md
touch docs/workflow.md
touch docs/sdd-spec-kit-adoption.md

touch docs/specs/sample-feature/spec.md
touch docs/specs/sample-feature/requirements.md
touch docs/specs/sample-feature/acceptance-criteria.md
touch docs/specs/sample-feature/clarifications.md
touch docs/specs/sample-feature/technical-plan.md
touch docs/specs/sample-feature/plan.md
touch docs/specs/sample-feature/research.md
touch docs/specs/sample-feature/data-model.md
touch docs/specs/sample-feature/contracts/README.md
touch docs/specs/sample-feature/quickstart.md
touch docs/specs/sample-feature/tasks.md
touch docs/specs/sample-feature/test-plan.md
touch docs/specs/sample-feature/traceability.md
touch docs/specs/sample-feature/analysis.md
touch docs/specs/sample-feature/checklist.md
touch docs/specs/sample-feature/self-review.md

touch .goose/recipes/sdd-specify.yaml
touch .goose/recipes/sdd-clarify.yaml
touch .goose/recipes/sdd-plan.yaml
touch .goose/recipes/sdd-analyze.yaml
touch .goose/recipes/sdd-implement.yaml
touch .goose/recipes/sdd-review-pr.yaml
touch .goose/recipes/sdd-research-docs.yaml

touch .opencode/oh-my-openagent.jsonc
touch .opencode/skills/human-governed-sdd/SKILL.md
touch .opencode/skills/backend-implementation/SKILL.md
touch .opencode/skills/self-review/SKILL.md

touch scripts/check-sdd-docs.sh
touch scripts/ai-guard.sh
touch scripts/run-tests.sh
touch scripts/create-pr-draft.sh
touch scripts/github-lib.sh
touch scripts/github-check.sh
touch scripts/github-issue-create.sh
touch scripts/github-issue-list.sh
touch scripts/github-issue-view.sh
touch scripts/github-pr-check.sh
touch scripts/github-pr-list.sh
touch scripts/github-pr-view.sh
touch scripts/load-env.sh
touch scripts/sdd-docs.sh
touch scripts/sdd-specify.sh
touch scripts/sdd-clarify.sh
touch scripts/sdd-plan.sh
touch scripts/sdd-analyze.sh
touch scripts/sdd-implement.sh
touch scripts/sdd-review-pr.sh

chmod +x scripts/*.sh
