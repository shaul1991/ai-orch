# shaul-ai-orch

Human-Governed SDD 기반 AI orchestration 템플릿이다. 이 repo는 `goose`, Codex, Claude Code, oh-my-openagent/OpenCode를 조합해 사람이 도메인/비즈니스 판단을 통제하고 AI가 문서화, 계획, 구현, 테스트, self-review, PR 초안 작성을 보조하도록 구성한다.

## 핵심 원칙

- 사람은 도메인 규칙, 비즈니스 정책, 범위 승인, PR 리뷰, 머지, 배포를 책임진다.
- AI는 승인된 SDD 문서 범위 안에서만 분석, 계획, 구현, 테스트, self-review, PR 초안을 수행한다.
- 요구사항과 acceptance criteria가 `Human Approved` 상태가 아니면 구현하지 않는다.
- AI는 PR 초안 생성 이후 멈추고 사람에게 제어권을 반환한다.

## 기본 역할 분담

이 프로젝트의 기본 언어는 한글이다.

| 작업 | 기본 담당 | 기본 provider/model |
|---|---|---|
| 문서 작성 | Codex | `codex-acp` / `gpt-5.5` |
| 리서치 | Codex | `codex-acp` / `gpt-5.5` |
| 요약 및 정리 | Codex | `codex-acp` / `gpt-5.5` |
| 아키텍처 설계 | Claude Code | `claude-code` / `default` |
| 구현 계획 | Claude Code | `claude-code` / `default` |
| 코드 작성 | Claude Code | `claude-code` / `default` |
| 리팩터링 | Claude Code | `claude-code` / `default` |
| 테스트 작성 | Claude Code | `claude-code` / `default` |
| 코드 self-review | Claude Code | `claude-code` / `default` |

작업별로 provider/model을 바꿀 수 있다.

```bash
AI_CODE_PROVIDER=codex-acp AI_CODE_MODEL=gpt-5.5 scripts/sdd-implement.sh sample-feature
AI_DOC_PROVIDER=claude-code AI_DOC_MODEL=default scripts/sdd-docs.sh "topic" docs/output.md
```

## 구성 요소

- `AGENTS.md`: repo 전체 agent 규칙
- `docs/ai-governance.md`: 사람/AI 권한 경계와 금지 규칙
- `docs/project-settings.md`: 한글 사용 및 Codex/Claude Code 역할 분담
- `docs/workflow.md`: SDD 작업 흐름
- `docs/specs/sample-feature/`: 샘플 SDD 문서
- `.goose/recipes/`: goose recipe
- `.opencode/`: oh-my-openagent/OpenCode 설정 및 skill
- `scripts/`: SDD 실행 wrapper, guard, test, PR helper

## 설치 전제 조건

macOS 기준 권장 도구:

```bash
brew --version
node --version
npm --version
bunx --version
gh --version
```

필수 AI 도구:

```bash
goose --version
codex --version
claude --version
opencode --version
bunx oh-my-openagent version
```

## 신규 환경 설치

### 1. repo 준비

```bash
git clone <repository-url>
cd shaul-ai-orch
```

### 2. CLI 설치

Homebrew를 사용하는 경우:

```bash
brew install block-goose-cli anomalyco/tap/opencode gh
```

Codex CLI와 ACP adapter:

```bash
npm install -g @openai/codex @zed-industries/codex-acp
```

Claude Code CLI는 Claude Code 공식 설치 절차에 따라 설치한다. 설치 후 다음 명령이 동작해야 한다.

```bash
claude --version
```

oh-my-openagent:

```bash
bunx oh-my-openagent install
```

doctor 확인:

```bash
bunx oh-my-openagent doctor
```

`comment-checker`가 없다고 나오면 설치한다.

```bash
npm install -g @code-yeongyu/comment-checker
```

### 3. Codex 인증

ChatGPT 계정으로 Codex를 인증한다.

```bash
codex login
codex login status
```

정상 상태 예:

```text
Logged in using ChatGPT
```

### 4. Claude Code 인증

Claude Code CLI에서 Claude 계정을 인증한다. 인증 후 다음 명령이 정상 동작해야 한다.

```bash
claude --version
```

이 프로젝트는 Anthropic API key를 필수로 요구하지 않는다. Claude Code 구독은 `claude-code` provider를 통해 사용한다.

### 5. goose provider 설정

기본 goose provider는 문서/리서치용 Codex로 설정한다.

```bash
goose configure
```

권장 선택:

```text
Configure Providers
Codex CLI
gpt-5.5
```

설정 확인:

```bash
rg 'GOOSE_PROVIDER|GOOSE_MODEL|CLAUDE_CODE_COMMAND' ~/.config/goose/config.yaml
```

권장 상태:

```yaml
CLAUDE_CODE_COMMAND: claude
GOOSE_PROVIDER: codex-acp
GOOSE_MODEL: gpt-5.5
```

### 6. GitHub CLI 설정

issue와 PR 관리는 GitHub CLI `gh`를 사용한다.

설치 확인:

```bash
gh --version
```

인증:

```bash
gh auth login
gh auth status
```

여러 GitHub 계정을 사용하는 경우 active account를 확인한다.

```bash
gh auth status
```

필요하면 계정을 전환한다.

```bash
gh auth switch
```

이 repo에서 issue/PR 명령이 대상 repository를 찾는 방식은 두 가지다.

1. git `origin` remote 사용
2. `.env`의 `AI_GITHUB_REPO=owner/repo` 사용

현재 repo에 remote가 있는지 확인:

```bash
git remote -v
```

remote가 없다면 `.env`에 `GH_REPO`를 설정한다.

```bash
AI_GITHUB_REPO=owner/shaul-ai-orch
AI_GITHUB_BASE_BRANCH=main
AI_GITHUB_ISSUE_LIMIT=20
AI_GITHUB_PR_LIMIT=20
```

GitHub 연결 확인:

```bash
scripts/github-check.sh
```

### 7. 설치 검증

```bash
scripts/check-sdd-docs.sh sample-feature
scripts/run-tests.sh
goose run --provider codex-acp --model gpt-5.5 --no-session --max-turns 1 --quiet --text 'Reply with exactly: CODEX_READY. Do not call tools.'
goose run --provider claude-code --model default --no-session --max-turns 1 --quiet --text 'Reply with exactly: CLAUDE_READY. Do not call tools.'
bunx oh-my-openagent doctor
scripts/github-check.sh
```

정상 응답:

```text
[SDD_GATE_PASSED] All required SDD documents exist and are approved.
CODEX_READY
CLAUDE_READY
System OK
```

### 8. 로컬 provider 설정

공유 템플릿은 `.env.example`에 둔다. 개인별 실제 설정은 `.env`에 둔다.

```bash
cp .env.example .env
```

`.env`는 git에 커밋하지 않는다. wrapper script는 실행 시 `.env`를 자동으로 읽는다.

예:

```bash
AI_CODE_PROVIDER=codex-acp
AI_CODE_MODEL=gpt-5.5

AI_DOC_PROVIDER=claude-code
AI_DOC_MODEL=default

AI_GITHUB_BASE_BRANCH=main
AI_GITHUB_ISSUE_LIMIT=20
AI_GITHUB_PR_LIMIT=20
```

shell에서 직접 넘긴 값이 `.env`보다 우선한다.

```bash
AI_CODE_PROVIDER=claude-code AI_CODE_MODEL=default scripts/sdd-implement.sh sample-feature
```

## 기본 사용법

### 문서/리서치 작업

Codex를 기본으로 사용한다.

```bash
scripts/sdd-docs.sh "Human-Governed SDD 운영 정책 정리" docs/research/sdd-policy.md
```

이 작업은 source code를 수정하지 않는 문서/분석 작업에 사용한다.

### SDD 계획 단계

Claude Code를 기본으로 사용한다.

```bash
scripts/sdd-plan.sh sample-feature
```

실행 내용:

- 요구사항과 acceptance criteria 읽기
- 관련 코드 구조 분석
- `technical-plan.md` 작성
- `tasks.md` 작성
- `test-plan.md` 작성
- 사람 검토 대기

### SDD 구현 단계

Claude Code를 기본으로 사용한다.

```bash
scripts/sdd-implement.sh sample-feature
```

실행 전 `scripts/check-sdd-docs.sh <feature>`가 통과해야 한다.

### SDD self-review 및 PR 초안

Claude Code를 기본으로 사용한다.

```bash
scripts/sdd-review-pr.sh sample-feature
```

실행 내용:

- 변경 파일 검토
- 요구사항/acceptance criteria 대비 구현 확인
- `self-review.md` 작성
- PR description 또는 draft PR 생성
- AI stop point 도달

## 새 feature 시작

```bash
FEATURE="your-feature-name"
mkdir -p "docs/specs/$FEATURE"
cp docs/specs/sample-feature/requirements.md "docs/specs/$FEATURE/requirements.md"
cp docs/specs/sample-feature/acceptance-criteria.md "docs/specs/$FEATURE/acceptance-criteria.md"
cp docs/specs/sample-feature/technical-plan.md "docs/specs/$FEATURE/technical-plan.md"
cp docs/specs/sample-feature/tasks.md "docs/specs/$FEATURE/tasks.md"
cp docs/specs/sample-feature/test-plan.md "docs/specs/$FEATURE/test-plan.md"
cp docs/specs/sample-feature/self-review.md "docs/specs/$FEATURE/self-review.md"
```

사람이 다음 파일을 실제 내용으로 작성하고 승인한다.

```text
docs/specs/{feature}/requirements.md
docs/specs/{feature}/acceptance-criteria.md
```

승인 상태:

```markdown
## Status

Human Approved
```

그 다음:

```bash
scripts/sdd-plan.sh "$FEATURE"
scripts/sdd-implement.sh "$FEATURE"
scripts/sdd-review-pr.sh "$FEATURE"
```

## provider/model override

기본값은 wrapper script와 `.env.example`에 정의한다.

```bash
AI_DOC_PROVIDER=codex-acp
AI_DOC_MODEL=gpt-5.5
AI_ARCH_PROVIDER=claude-code
AI_ARCH_MODEL=default
AI_CODE_PROVIDER=claude-code
AI_CODE_MODEL=default
AI_REVIEW_PROVIDER=claude-code
AI_REVIEW_MODEL=default
```

개인별 기본값은 `.env`에서 관리한다.

```bash
cp .env.example .env
vi .env
```

문서 작업을 Claude Code로 실행:

```bash
AI_DOC_PROVIDER=claude-code AI_DOC_MODEL=default scripts/sdd-docs.sh "문서 주제" docs/output.md
```

구현 작업을 Codex로 실행:

```bash
AI_CODE_PROVIDER=codex-acp AI_CODE_MODEL=gpt-5.5 scripts/sdd-implement.sh sample-feature
```

review 작업을 Codex로 실행:

```bash
AI_REVIEW_PROVIDER=codex-acp AI_REVIEW_MODEL=gpt-5.5 scripts/sdd-review-pr.sh sample-feature
```

goose recipe를 직접 실행:

```bash
goose run --provider codex-acp --model gpt-5.5 --recipe .goose/recipes/sdd-research-docs.yaml --params topic="topic" --params output=docs/output.md
goose run --provider claude-code --model default --recipe .goose/recipes/sdd-plan.yaml --params feature=sample-feature
```

## guard scripts

SDD 문서 승인 확인:

```bash
scripts/check-sdd-docs.sh sample-feature
```

위험 명령 차단 wrapper:

```bash
scripts/ai-guard.sh git status --short
```

프로젝트 테스트:

```bash
scripts/run-tests.sh
```

실제 프로젝트에 적용할 때는 `scripts/run-tests.sh`를 기술 스택에 맞게 수정한다.

예:

```bash
# Node.js / TypeScript
pnpm lint
pnpm test
pnpm typecheck

# Laravel / PHP
php artisan test

# Kotlin / Spring
./gradlew test
```

Draft PR:

```bash
scripts/create-pr-draft.sh sample-feature
```

## GitHub issue/PR 관리

GitHub 명령은 `gh`를 직접 사용해도 되고, repo wrapper script를 사용해도 된다. wrapper script는 `.env`를 자동으로 읽고 `AI_GITHUB_REPO` 또는 git `origin` remote를 기준으로 대상 repository를 결정한다.

상태 확인:

```bash
scripts/github-check.sh
```

issue 목록:

```bash
scripts/github-issue-list.sh
scripts/github-issue-list.sh closed
```

issue 보기:

```bash
scripts/github-issue-view.sh 123
```

issue 생성:

```bash
scripts/github-issue-create.sh "Issue title" "Issue body"
scripts/github-issue-create.sh "Issue title" docs/issues/body.md "bug,priority-high"
```

PR 목록:

```bash
scripts/github-pr-list.sh
scripts/github-pr-list.sh closed
```

PR 보기:

```bash
scripts/github-pr-view.sh 123
```

PR check 확인:

```bash
scripts/github-pr-check.sh
scripts/github-pr-check.sh 123
```

SDD self-review 후 draft PR 생성:

```bash
scripts/create-pr-draft.sh sample-feature
```

AI는 PR 생성 또는 PR 초안 작성까지만 수행한다. PR 리뷰, 머지, 배포 판단은 사람이 한다.

## 운영 규칙

AI가 해도 되는 일:

- 코드 읽기
- 구조 분석
- 기술 계획 작성
- 승인된 task 구현
- 테스트 작성/실행
- self-review 작성
- PR 초안 작성

AI가 하면 안 되는 일:

- 비즈니스 정책 결정
- 도메인 규칙 임의 변경
- 승인되지 않은 기능 추가
- 인증/인가/결제/가격 정책 임의 변경
- PR 머지
- 배포
- force push
- production DB 변경

중단 조건:

- 요구사항 없음
- acceptance criteria 없음
- `Human Approved` 상태 아님
- 도메인/비즈니스 규칙 모호
- 보안/권한 정책 불명확
- 승인 범위 밖 구현 필요
- PR draft 생성 완료

## 문제 해결

### Codex 인증 확인

```bash
codex login status
```

정상:

```text
Logged in using ChatGPT
```

### Claude Code 확인

```bash
claude --version
goose run --provider claude-code --model default --no-session --max-turns 1 --quiet --text 'Reply with exactly: CLAUDE_READY.'
```

### goose provider 확인

```bash
rg 'GOOSE_PROVIDER|GOOSE_MODEL|CLAUDE_CODE_COMMAND' ~/.config/goose/config.yaml
```

### oh-my-openagent 확인

```bash
bunx oh-my-openagent doctor
```

`comment-checker unavailable`가 나오면:

```bash
npm install -g @code-yeongyu/comment-checker
```

설치 후에도 못 찾으면 `comment-checker`가 PATH에 있는지 확인한다.

```bash
command -v comment-checker
```

### GitHub CLI 확인

```bash
gh --version
gh auth status
scripts/github-check.sh
```

`Could not resolve GitHub repository`가 나오면 다음 중 하나를 설정한다.

```bash
git remote add origin https://github.com/<owner>/<repo>.git
```

또는 `.env`:

```bash
AI_GITHUB_REPO=<owner>/<repo>
```

여러 계정이 있고 active account가 다르면:

```bash
gh auth switch
```

### recipe 렌더링 확인

```bash
goose run --recipe .goose/recipes/sdd-plan.yaml --params feature=sample-feature --render-recipe
goose run --recipe .goose/recipes/sdd-implement.yaml --params feature=sample-feature --render-recipe
goose run --recipe .goose/recipes/sdd-review-pr.yaml --params feature=sample-feature --render-recipe
```

## 커밋 전 확인

```bash
git status --short
scripts/check-sdd-docs.sh sample-feature
scripts/run-tests.sh
```

로컬 자료와 캐시는 `.gitignore`로 제외한다.

- `.local/`
- `.log/`
- `.opencode/node_modules/`
- `.opencode/package*.json`
- `.env*`
