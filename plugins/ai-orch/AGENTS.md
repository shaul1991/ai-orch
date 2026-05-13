# Project Agent Rules

이 repository는 Human-Governed Spec-Driven Development를 따른다.

## 적용 대상

- `AGENTS.md`는 Codex와 AGENTS.md를 인식하는 agent의 기본 지침이다.
- Claude Code는 `CLAUDE.md`를 우선 읽을 수 있으므로, `CLAUDE.md`는 이 파일을 source of truth로 참조한다.
- plugin이 다른 repository에 설치된 경우, `scripts/ai-orch.sh init`이 target repository에 `AGENTS.md`가 없거나 비어있으면 marketplace clone의 canonical `AGENTS.md`를 복사한다. 이미 내용이 있는 `AGENTS.md`는 덮어쓰지 않는다.

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

1. `.ai-orch/specify/memory/constitution.md`
2. `.ai-orch/docs/ai-governance.md`
3. `.ai-orch/docs/project-settings.md`
4. `docs/specs/{feature}/spec.md`
5. `docs/specs/{feature}/requirements.md`
6. `docs/specs/{feature}/acceptance-criteria.md`
7. `docs/specs/{feature}/clarifications.md`
8. 관련 기존 code

처음 3 개는 plugin 이 init 시 `.ai-orch/` 하위로 bootstrap 하는 reference 문서다 (target repo 의 git history 에는 commit 하지 않음). pre-0.4.5 layout 의 `.specify/memory/constitution.md`, `docs/ai-governance.md`, `docs/project-settings.md` 가 그대로 남아 있는 경우에는 그 경로를 사용한다.

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

- shared deny/allow: `.ai-orch/protect.shared` (init 시 plugin canonical 정책에서 bootstrap. pre-0.4.5 target 은 루트 `ai-orch.protect` 를 그대로 사용해도 됨)
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
- requested file이 `.ai-orch/protect.shared` (또는 legacy `ai-orch.protect`) 또는 `.ai-orch/protect.local`에 match되고 local human-confirmed allow가 없음
- PR draft가 생성됨

## Review Loop Discipline

자동 PR review bot (Codex, CodeRabbit 등) 의 응답 round 처리 규칙.

- 동일 PR 의 review round 는 **최대 3 까지만 즉시 처리**한다. round 4 이상은 자동 수정 루프를 멈추고 사용자에게 escalate 한다.
- round 카운트: 한 번의 push 에 대해 도착한 bot 의 review 묶음을 1 round 로 본다. 같은 round 에 여러 bot 이 응답하면 1 round 로 합산.
- 한 round 의 review 가 현재 PR 의 변경 라인 밖에서도 **동일 convention 의 수정**을 요구하면, 별도 issue 를 생성하고 그 issue 의 branch/PR 에서 처리한다. 현재 PR 의 scope 는 본래 변경 라인에 한정한다.
- 예외: 발견된 cross-cutting fix 가 **현재 PR 의 회귀를 닫기 위해 필수** (예: 같은 PR 변경의 직접 의존 chain) 인 경우에만 현재 PR 에서 같이 처리한다.
- 동일 convention 여부 판단 기준: 같은 코드 패턴/관용구/규칙을 다른 파일에서도 적용해야 하는가. 같은 review 가 지적한 라인 자체의 fix 는 cross-cutting 이 아니라 본 round 처리.
- escalate 시 보고 내용: 남은 review 목록, 패턴 / cross-cutting 여부 판정, 권장 follow-up issue 후보.

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
