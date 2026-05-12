# AI Orch Local State

`.ai-orch/`는 AI Orch의 local/개인별 실행 이력 cache를 저장하는 디렉터리다.

현재 plugin version: `0.3.0`

## Git Policy

- 이 파일만 git에 추적한다.
- 실제 실행 이력은 git에 커밋하지 않는다.
- branch별 status와 run log는 개인 로컬 상태로만 유지한다.

## Generated Paths

```text
.ai-orch/
├── README.md          # tracked
├── branches/          # ignored
│   └── {branch}.md    # branch별 flow checklist
├── state/             # ignored
│   └── {branch}.state # script가 읽는 key-value cache
└── runs/              # ignored
    └── *.md           # flow 실행 event log
```

## Source Of Truth

- 공유 산출물: `docs/specs/{feature}/...`
- local 실행 상태: `.ai-orch/branches/{branch}.md`
- PR/merge/release 판단: human-owned

## Initialization

`scripts/ai-orch.sh init`은 이 파일과 `.gitignore`의 AI Orch local state 규칙을 보장한다.
