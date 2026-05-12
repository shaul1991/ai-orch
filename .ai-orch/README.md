# AI Orch Local State

`.ai-orch/`는 AI Orch의 local/개인별 실행 이력 cache를 저장하는 디렉터리다.

현재 plugin version: `0.4.0`

## Git 정책

- 이 파일만 git에 추적한다.
- 실제 실행 이력은 git에 커밋하지 않는다.
- branch별 status와 run log는 개인 로컬 상태로만 유지한다.

## 생성 경로

```text
.ai-orch/
├── README.md          # tracked
├── setting.json       # tracked, AI Orch 공유 설정
├── settings.example.json # tracked, 설정 key/default 안내
├── setting.local.json # ignored, 개인별 설정 override
├── protect.local      # ignored, 개인별 추가 deny policy
├── protect.allow.local # ignored, 사용자 확인 후 등록한 allow policy
├── branches/          # ignored
│   └── {branch}.md    # branch별 flow checklist
├── state/             # ignored
│   └── {branch}.state # script가 읽는 key-value cache
└── runs/              # ignored
    └── *.md           # flow 실행 event log
```

## 기준 정보

- 공유 산출물: `docs/specs/{feature}/...`
- local 실행 상태: `.ai-orch/branches/{branch}.md`
- PR/merge/release 판단: human-owned

## 초기화

`scripts/ai-orch.sh init`은 이 파일과 `.gitignore`의 AI Orch local state 규칙을 보장한다.

## 보호 정책

- 공유 보호 정책: `ai-orch.protect`
- 개인별 추가 차단: `.ai-orch/protect.local`
- 사용자 확인 후 local 허용: `.ai-orch/protect.allow.local`
- 접근 확인: `scripts/ai-orch.sh protect check-read <path>`
