# Implementation Plan: Sample Feature

Branch: `sample-feature`
Date: 2026-05-12
Spec: `docs/specs/sample-feature/spec.md`

## Summary

`sample-feature`는 Human-Governed SDD 템플릿과 `spec-kit` 호환 산출물이 같은 feature directory 안에서 공존하는지 검증한다.

## Technical Context

- Language / Version: Bash scripts and Markdown documents
- Framework: none
- Runtime: local shell
- Database: none
- External APIs: none
- Testing: `bash -n`, `scripts/check-sdd-docs.sh`, `scripts/run-tests.sh`

## Constitution Check

Gate:
- `.specify/memory/constitution.md`를 읽는다.
- 사람이 승인한 `requirements.md`와 `acceptance-criteria.md` 없이는 구현하지 않는다.
- 미해결 clarification marker가 남아 있으면 구현하지 않는다.

Result: Pass

## Project Structure

### Documentation

```text
docs/specs/sample-feature/
├── spec.md
├── requirements.md
├── acceptance-criteria.md
├── clarifications.md
├── technical-plan.md
├── plan.md
├── research.md
├── data-model.md
├── contracts/
├── quickstart.md
├── tasks.md
├── test-plan.md
├── traceability.md
├── analysis.md
├── checklist.md
└── self-review.md
```

### Source Code

No application source code is changed by this sample feature.

## Complexity Tracking

No constitution violations.
