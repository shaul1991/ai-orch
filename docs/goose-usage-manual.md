# Goose 사용 매뉴얼

작성일: 2026-05-12  
대상: 이 저장소에서 Human-Governed SDD workflow를 실행하는 사용자  
검증한 로컬 Goose 버전: `1.33.1`

## 1. 역할

이 저장소에서 `goose`는 AI orchestration 실행 레이어다.

- `scripts/sdd-*.sh` wrapper는 `.ai-orch/setting.local.json`과 `.ai-orch/setting.json`을 읽고 provider/model을 설정한다.
- `.goose/recipes/*.yaml`은 각 SDD 단계의 agent instruction을 정의한다.
- `goose run`은 recipe와 parameter를 받아 실제 AI 작업을 실행한다.

일반 사용자는 가능하면 `goose run`을 직접 호출하지 말고 `scripts/` wrapper를 사용한다. 직접 실행은 recipe rendering, debugging, 일회성 실험에만 사용한다.

## 2. 전제 조건 확인

```bash
goose --version
codex --version
claude --version
```

GitHub 작업까지 할 경우:

```bash
gh --version
gh auth status
```

프로젝트 기본 검증:

```bash
scripts/check-sdd-docs.sh sample-feature
scripts/run-tests.sh
```

## 3. Provider와 Model 설정

공유 기본값은 `.ai-orch/setting.json`에 있다. 사용할 수 있는 key와 기본값 설명은 `.ai-orch/settings.example.json`에서 확인한다.

```bash
cp .ai-orch/settings.example.json .ai-orch/setting.local.json
```

주요 변수:

```json
{
  "AI_DOC_PROVIDER": "codex-acp",
  "AI_DOC_MODEL": "gpt-5.5",
  "AI_ARCH_PROVIDER": "claude-code",
  "AI_ARCH_MODEL": "default",
  "AI_CODE_PROVIDER": "claude-code",
  "AI_CODE_MODEL": "default",
  "AI_REVIEW_PROVIDER": "claude-code",
  "AI_REVIEW_MODEL": "default"
}
```

우선순위는 다음과 같다.

1. shell에서 직접 넘긴 환경 변수
2. `.ai-orch/setting.local.json`
3. `.ai-orch/setting.json`
4. wrapper script의 fallback 기본값

예:

```bash
AI_CODE_PROVIDER=codex-acp AI_CODE_MODEL=gpt-5.5 scripts/sdd-implement.sh sample-feature
```

## 4. 기본 SDD 실행 흐름

### 4.1 Specify

기능 요구사항과 acceptance criteria 초안을 만든다. AI는 `Human Approved`를 직접 부여하지 않는다.

```bash
scripts/sdd-specify.sh your-feature-name "기능 설명"
```

생성/갱신 대상:

- `docs/specs/{feature}/spec.md`
- `docs/specs/{feature}/requirements.md`
- `docs/specs/{feature}/acceptance-criteria.md`
- `docs/specs/{feature}/clarifications.md`

### 4.2 Clarify

요구사항의 모호성, 누락된 domain/business/security 결정을 찾는다.

```bash
scripts/sdd-clarify.sh your-feature-name
```

결정이 필요하면 `[HUMAN_DECISION_REQUIRED]`로 중단해야 한다.

### 4.3 Plan

승인된 요구사항을 기준으로 기술 계획, 작업, 테스트 계획, traceability를 만든다.

```bash
scripts/sdd-plan.sh your-feature-name
```

주요 산출물:

- `technical-plan.md`
- `plan.md`
- `research.md`
- `data-model.md`
- `contracts/`
- `quickstart.md`
- `tasks.md`
- `test-plan.md`
- `traceability.md`

### 4.4 Analyze

구현 전에 SDD 산출물 간 일관성을 확인한다.

```bash
scripts/sdd-analyze.sh your-feature-name
```

주요 산출물:

- `analysis.md`
- `checklist.md`

### 4.5 Gate

구현 직전 반드시 통과해야 하는 hard gate다.

```bash
scripts/check-sdd-docs.sh your-feature-name
```

검증 항목:

- `.specify/memory/constitution.md` 존재
- 필수 feature 문서 존재
- `requirements.md`, `acceptance-criteria.md`의 `Human Approved`
- 미해결 clarification marker 부재
- `tasks.md`의 task ID와 파일 경로
- `traceability.md`의 requirement-task-test 연결

### 4.6 Implement

승인된 task만 구현한다.

```bash
scripts/sdd-implement.sh your-feature-name
```

이 단계는 내부에서 먼저 `scripts/check-sdd-docs.sh {feature}`를 실행하도록 recipe가 지시한다.

### 4.7 Review and PR Draft

구현 결과를 self-review하고 draft PR을 준비한다.

```bash
scripts/sdd-review-pr.sh your-feature-name
```

AI는 draft PR 생성 또는 PR description 작성 후 멈춘다. PR review, merge, release는 사람이 결정한다.

## 5. 문서/리서치 작업

source code를 수정하지 않는 문서 작업은 `sdd-docs`를 사용한다.

```bash
scripts/sdd-docs.sh "조사 주제" docs/output.md
```

예:

```bash
scripts/sdd-docs.sh "Goose 기반 SDD 운영 정책 정리" docs/research/goose-sdd-policy.md
```

## 6. Goose 직접 실행

Wrapper가 부족한 경우에만 직접 실행한다.

### 6.1 단문 실행

```bash
goose run \
  --provider codex-acp \
  --model gpt-5.5 \
  --no-session \
  --max-turns 1 \
  --quiet \
  --text 'Reply with exactly: CODEX_READY. Do not call tools.'
```

### 6.2 Recipe 실행

```bash
goose run \
  --provider claude-code \
  --model default \
  --recipe .goose/recipes/sdd-plan.yaml \
  --params feature=sample-feature
```

### 6.3 Recipe 설명 확인

```bash
goose run \
  --recipe .goose/recipes/sdd-plan.yaml \
  --explain
```

### 6.4 Recipe 렌더링 확인

실행하지 않고 parameter가 반영된 recipe만 확인한다.

```bash
goose run \
  --recipe .goose/recipes/sdd-plan.yaml \
  --params feature=sample-feature \
  --render-recipe
```

## 7. 자주 쓰는 운영 명령

문서 gate:

```bash
scripts/check-sdd-docs.sh sample-feature
```

테스트:

```bash
scripts/run-tests.sh
```

프로젝트별 테스트 명령을 임시 지정:

```bash
AI_TEST_COMMANDS=$'pnpm lint\npnpm test\npnpm typecheck' scripts/run-tests.sh
```

GitHub 연결 확인:

```bash
scripts/github-check.sh
```

Draft PR:

```bash
scripts/create-pr-draft.sh your-feature-name
```

## 8. 안전 규칙

다음 상황에서는 구현을 진행하지 않는다.

- `requirements.md` 또는 `acceptance-criteria.md`가 `Human Approved` 상태가 아님
- domain/business/security/authorization 결정이 불명확함
- `scripts/check-sdd-docs.sh {feature}` 실패
- 구현이 `tasks.md` 범위를 벗어남
- 인증, 인가, 결제, 가격, user permission, customer-facing policy에 영향이 있지만 명시 승인이 없음

금지 명령:

- `git merge`
- `gh pr merge`
- `git push --force`
- production deploy command
- destructive database command
- explicit approval 없는 migration rollback

위험 명령을 감싸야 할 때:

```bash
scripts/ai-guard.sh <command>
```

## 9. Troubleshooting

### Goose provider 설정 확인

```bash
rg 'GOOSE_PROVIDER|GOOSE_MODEL|CLAUDE_CODE_COMMAND' ~/.config/goose/config.yaml
```

### Codex 연결 확인

```bash
codex login status
goose run --provider codex-acp --model gpt-5.5 --no-session --max-turns 1 --quiet --text 'Reply with exactly: CODEX_READY. Do not call tools.'
```

### Claude Code 연결 확인

```bash
claude --version
goose run --provider claude-code --model default --no-session --max-turns 1 --quiet --text 'Reply with exactly: CLAUDE_READY. Do not call tools.'
```

### Recipe parameter 오류

먼저 렌더링으로 확인한다.

```bash
goose run --recipe .goose/recipes/sdd-plan.yaml --params feature=sample-feature --render-recipe
```

### SDD gate 실패

실패 메시지의 파일을 먼저 수정한다.

```bash
scripts/check-sdd-docs.sh your-feature-name
```

일반 원인:

- 필수 문서 누락
- `Human Approved` 누락
- clarification marker 잔존
- `tasks.md`에 `T001` 같은 task ID 누락
- `traceability.md`에 requirement-task-test 연결 누락
