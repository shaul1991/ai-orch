# Spec Kit 기반 SDD 도입 기준

작성일: 2026-05-12

## 결론

이 저장소는 `spec-kit`를 전면 대체 도구로 도입하지 않고, 현재 `Human-Governed SDD`를 상위 정책으로 유지하면서 `spec-kit`의 산출물 구조와 검증 단계를 흡수한다.

이유는 다음과 같다.

- 이미 `AGENTS.md`, `docs/ai-governance.md`, `docs/workflow.md`, goose recipe, wrapper script가 존재한다.
- 사람의 도메인/비즈니스 승인권과 AI의 구현 책임 분리가 저장소의 핵심 가치다.
- `spec-kit`의 `constitution`, `specify`, `clarify`, `plan`, `tasks`, `analyze`, `implement` 흐름은 현재 구조에 잘 맞지만, upstream 기본값을 그대로 실행하면 기존 governance와 문서 경로가 흔들릴 수 있다.

## 도입 방식

- `.specify/memory/constitution.md`를 프로젝트 최상위 정책으로 추가한다.
- 기능별 문서는 기존 `docs/specs/{feature}/` 경로를 유지한다.
- 기존 필수 문서인 `requirements.md`, `acceptance-criteria.md`, `technical-plan.md`, `tasks.md`, `test-plan.md`는 계속 유지한다.
- `spec-kit` 호환 문서인 `spec.md`, `clarifications.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md`, `traceability.md`, `analysis.md`, `checklist.md`를 추가한다.
- `scripts/check-sdd-docs.sh`를 구현 전 hard gate로 사용한다.

## 공식 버전 기준

도입 검토 시점의 기준 버전은 `github/spec-kit` `v0.8.7`이다.

권장 설치 방식은 전역 설치가 아니라 버전 고정 확인이다.

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v0.8.7
specify version
```

이 저장소에서는 `specify init --force`를 바로 실행하지 않는다. 필요하면 임시 디렉터리에서 `specify init` 결과를 확인한 뒤 필요한 템플릿과 명령만 수동 이식한다.

## 운영 원칙

- `requirements.md`와 `acceptance-criteria.md`는 사람이 승인한다.
- `spec.md`와 `clarifications.md`는 AI가 초안을 도울 수 있지만, `[NEEDS CLARIFICATION]`이 남아 있으면 구현하지 않는다.
- `plan.md`와 `technical-plan.md`는 같은 기술 결정을 공유한다. `plan.md`는 `spec-kit` 호환 산출물, `technical-plan.md`는 기존 Human-Governed SDD 산출물이다.
- API, 이벤트, DB 변경이 있는 기능은 `contracts/`와 `data-model.md`에 반영한다.
- `traceability.md`에는 요구사항, 사용자 스토리, 작업, 테스트 연결을 기록한다.
- `analysis.md`와 `checklist.md`는 구현 직전 cross-artifact consistency gate로 사용한다.

## 금지 사항

- `spec-kit` upstream 기본 command가 생성한 문서가 이 constitution과 충돌할 경우 그대로 커밋하지 않는다.
- AI는 `Human Approved` 상태를 스스로 부여하지 않는다.
- AI는 domain/business ambiguity를 임의로 해결하지 않는다.
- PR draft 이후 merge/release 판단은 사람이 한다.
