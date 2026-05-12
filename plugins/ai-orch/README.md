# AI Orch Plugin

`ai-orch`용 repo-local command plugin이다.

이 plugin은 Claude Code/Codex native command UX를 노출하고, 실제 실행은 `scripts/ai-orch.sh`로 위임한다. Claude Code는 `commands/`를 사용하고, Codex는 `skills/`를 사용한다.

## Commands

- `/ai-orch:help`
- `/ai-orch:init`
- `/ai-orch:status [feature]`
- `/ai-orch:docs <topic> <output-markdown-path>`
- `/ai-orch:feature <feature> [description]`
- `/ai-orch:plan <feature>`
- `/ai-orch:ready <feature>`
- `/ai-orch:implement <feature>`
- `/ai-orch:review <feature>`
- `/ai-orch:pr <feature>`

## 설치

Claude Code 안에서:

```text
/plugin marketplace add shaul1991/ai-orch
/plugin install ai-orch@ai-orch
```

Claude Code CLI에서:

```bash
claude plugin marketplace add shaul1991/ai-orch
claude plugin install -s project ai-orch@ai-orch
```

Codex:

```bash
codex plugin marketplace add shaul1991/ai-orch
```

Codex는 plugin skill을 통해 같은 `/ai-orch:*` hinting을 노출한다. 설치 후 plugin 상세에 `Skills`가 표시되어야 한다.

local clone을 직접 등록할 때는 repo root에서 `claude plugin marketplace add .` 또는 `codex plugin marketplace add .`를 실행한다.

이 plugin은 SDD 로직을 직접 구현하지 않는다. 실행 동작의 source of truth는 repository의 shell wrapper다.

`/ai-orch:help`와 `/ai-orch:status`는 현재 branch의 local checklist를 `.ai-orch/branches/{branch}.md` 기준으로 보여준다. `.ai-orch/`의 실행 이력은 개인 cache이므로 git에 커밋하지 않는다.
