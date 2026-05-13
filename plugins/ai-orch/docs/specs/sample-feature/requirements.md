# Requirements: Sample Feature

## Status

Human Approved

<!-- Change to `Human Approved` only after human review. -->

## Business Goal

Human-Governed SDD 템플릿이 `spec-kit` 호환 산출물과 함께 구현 전 gate를 통과하는지 검증한다.

## User Problem

운영자는 실제 기능 구현 전에 SDD 문서 세트, 승인 상태, task 추적성, 검증 script가 정상 동작하는지 확인해야 한다.

## Scope

### In Scope

- `docs/specs/sample-feature/` 문서 구조 검증
- 구현 전 SDD gate 검증
- `spec-kit` 호환 산출물 예시 제공

### Out of Scope

- 애플리케이션 기능 구현
- API, DB, 외부 시스템 변경

## Domain Rules

- DR-001: 사람은 domain/business 결정을 소유한다.
- DR-002: AI는 승인된 SDD 문서 범위 안에서만 계획, 구현, 테스트, self-review, PR draft를 수행한다.
- DR-003: 미해결 clarification marker가 남아 있으면 구현을 시작하지 않는다.

## User Stories

- US-001: 운영자는 `sample-feature`를 통해 필수 SDD 문서와 gate 동작을 검증할 수 있다.

## Functional Requirements

- FR-001: The SDD gate MUST verify required feature documents before implementation.
- FR-002: The SDD gate MUST require `Human Approved` in `requirements.md` and `acceptance-criteria.md`.
- FR-003: The SDD gate MUST reject unresolved clarification markers in feature documents.
- FR-004: The SDD workflow MUST preserve the human-owned domain and business decision boundary.

## Non-Functional Requirements

- NFR-001: Gate failure messages must identify the missing or invalid artifact.
- NFR-002: Scripts must exit non-zero when validation fails.

## Human Decisions

| Decision | Owner | Status | Notes |
|---|---|---|---|
| Keep `docs/specs/{feature}` path | Human | Human Approved | Add `spec-kit` compatibility without moving paths. |
| Require Human Approved before implementation | Human | Human Approved | Applies to `requirements.md` and `acceptance-criteria.md`. |

## AI Must Not Decide

- Business policy
- Domain behavior not specified above
