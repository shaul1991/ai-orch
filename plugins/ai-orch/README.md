# AI Orch Plugin

`ai-orch`용 repo-local command plugin이다.

이 plugin은 Claude Code/Codex native command를 노출하고, 실제 실행은 `scripts/ai-orch.sh`로 위임한다.

## Commands

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

Codex CLI는 marketplace 등록 명령만 제공한다. command hinting은 Codex의 plugin 설치/활성화 UI 또는 session plugin 선택에서 `ai-orch`를 활성화한 뒤 확인한다.

local clone을 직접 등록할 때는 repo root에서 `claude plugin marketplace add .` 또는 `codex plugin marketplace add .`를 실행한다.

이 plugin은 SDD 로직을 직접 구현하지 않는다. 실행 동작의 source of truth는 repository의 shell wrapper다.
