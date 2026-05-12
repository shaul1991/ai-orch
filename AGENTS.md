# Project Agent Rules

이 repository는 Human-Governed Spec-Driven Development를 따른다.

## 적용 대상

- `AGENTS.md`는 Codex와 AGENTS.md를 인식하는 agent의 기본 지침이다.
- Claude Code는 `CLAUDE.md`를 우선 읽을 수 있으므로, `CLAUDE.md`는 이 파일을 source of truth로 참조한다.
- plugin만 다른 repository에 설치하는 경우, 이 repository의 `AGENTS.md`가 target repository로 자동 복사되지는 않는다. target repository에도 같은 정책이 필요하면 `AGENTS.md` 또는 `CLAUDE.md`를 별도로 둔다.

## 기본 언어

이 repository의 주 사용 언어는 한국어다.

- 사용자에게 보여주는 설명, planning note, review note, repository 문서는 기본적으로 한국어로 작성한다.
- code identifier, command, file path, API name, provider/model name, quoted source text는 원문을 유지한다.
- shell script의 실행 output tag, command/action name은 영어를 유지한다.

## Core Principle

Human owns domain and business decisions.  
AI owns technical planning, implementation, testing, self-review, and PR draft only.

## Default Agent Routing

기본 routing:

- Codex: 문서, 리서치, 요약, governance note, non-code analysis
- Claude Code: coding, architecture design, implementation planning, refactoring, tests, code review
- 사용자는 작업마다 routing을 override할 수 있다.

가능하면 `scripts/` wrapper를 사용한다. wrapper는 `.ai-orch/setting.local.json`과 `.ai-orch/setting.json`을 통해 provider/model override를 읽는다.

주요 설정 key:

- `AI_DOC_PROVIDER`, `AI_DOC_MODEL`
- `AI_ARCH_PROVIDER`, `AI_ARCH_MODEL`
- `AI_CODE_PROVIDER`, `AI_CODE_MODEL`
- `AI_REVIEW_PROVIDER`, `AI_REVIEW_MODEL`
- `AI_GITHUB_ACCOUNT`, `AI_GITHUB_REPO`

설정 우선순위:

1. shell environment
2. `.ai-orch/setting.local.json`
3. `.ai-orch/setting.json`
4. wrapper fallback default

## Native Command Entry Points

Claude Code/Codex plugin command는 실제 동작을 `scripts/ai-orch.sh`에 위임한다.

주요 command:

- `/ai-orch:help`
- `/ai-orch:init`
- `/ai-orch:protect <action> [args...]`
- `/ai-orch:status [feature]`
- `/ai-orch:docs <topic> <output-markdown-path>`
- `/ai-orch:feature <feature> [description]`
- `/ai-orch:plan <feature>`
- `/ai-orch:ready <feature>`
- `/ai-orch:implement <feature>`
- `/ai-orch:review <feature>`
- `/ai-orch:pr <feature>`

plugin 설치 직후 target repository의 최초 필수 command는 다음이다.

```bash
scripts/ai-orch.sh init
```

init이 완료되기 전에는 `status`와 실행형 flow가 멈추고 init 실행을 안내해야 한다.

## Required Reading Order

구현 전에는 다음 순서로 읽는다.

1. `.specify/memory/constitution.md`
2. `docs/ai-governance.md`
3. `docs/project-settings.md`
4. `docs/specs/{feature}/spec.md`
5. `docs/specs/{feature}/requirements.md`
6. `docs/specs/{feature}/acceptance-criteria.md`
7. `docs/specs/{feature}/clarifications.md`
8. 관련 기존 code

## Implementation Gate

source code를 수정하려면 다음이 모두 존재해야 한다.

- `spec.md`
- `requirements.md`
- `acceptance-criteria.md`
- `clarifications.md`
- `technical-plan.md`
- `plan.md`
- `research.md`
- `data-model.md`
- `contracts/`
- `quickstart.md`
- `tasks.md`
- `test-plan.md`
- `traceability.md`
- `analysis.md`
- `checklist.md`

`requirements.md`와 `acceptance-criteria.md`는 반드시 `Human Approved`를 포함해야 한다.

## Protected Files

secret/critical file은 읽기, 수정, 삭제, 요약, 노출 전에 보호 정책을 확인한다.

확인 command:

```bash
scripts/ai-orch.sh protect check-read <path>
scripts/ai-orch.sh protect check-write <path>
```

보호 정책 파일:

- shared deny/allow: `ai-orch.protect`
- local deny: `.ai-orch/protect.local`
- local human-confirmed allow: `.ai-orch/protect.allow.local`

보호 path가 차단되면 agent가 임의로 우회하지 않는다. 사용자가 명시적으로 확인한 경우에만 사용자가 local allow command를 실행한다.

예:

```bash
scripts/ai-orch.sh protect allow-read .env
```

## Stop Conditions

다음 경우 즉시 멈춘다.

- business rule이 누락됨
- domain behavior가 모호함
- requirement가 기존 behavior와 충돌함
- feature 문서에 unresolved clarification marker가 있음
- security 또는 authorization policy가 불명확함
- payment, pricing, user permission, customer-facing policy에 영향이 있음
- requested file이 `ai-orch.protect` 또는 `.ai-orch/protect.local`에 match되고 local human-confirmed allow가 없음
- PR draft가 생성됨

## Forbidden Actions

절대 실행하지 않는다.

- `git merge`
- `gh pr merge`
- `git push --force`
- production deploy command
- destructive database command
- migration rollback command without explicit human approval

## Verification

변경 후 가능한 범위에서 다음을 실행한다.

```bash
scripts/run-tests.sh
claude plugin validate plugins/ai-orch
git diff --check
```
