# Clarifications: Sample Feature

## C-001

Question: `sample-feature`는 실제 애플리케이션 코드를 구현하는가?
Answer: 아니다. 이 feature는 SDD 문서 구조와 gate 검증만 다룬다.
Decided by: Human
Date: 2026-05-12
Impact:
- Source code 변경은 범위 밖이다.
- 검증 대상은 SDD 문서와 script 동작이다.

## C-002

Question: `spec-kit` 산출물은 기존 `docs/specs/{feature}` 경로를 대체하는가?
Answer: 아니다. 기존 경로를 유지하고 호환 산출물을 추가한다.
Decided by: Human
Date: 2026-05-12
Impact:
- `docs/specs/sample-feature/` 아래에 기존 문서와 `spec-kit` 호환 문서를 함께 둔다.
