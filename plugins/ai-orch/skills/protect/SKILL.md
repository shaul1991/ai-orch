---
name: protect
description: AI Orch secret/critical file 접근 보호 정책을 확인하고 local user-confirmed allow를 관리한다. 사용자가 `/ai-orch:protect`, ai-orch protect, secret 파일 접근 차단 확인을 요청할 때 사용한다.
---

# AI Orch Protect

`scripts/ai-orch.sh protect <action> [args...]`로 위임한다.

## Instructions

1. secret/critical file 접근 보호 정책을 확인하거나 local user-confirmed allow를 관리한다고 설명한다.
2. repository root에서 `scripts/ai-orch.sh protect <action> [args...]`를 실행한다.
3. 보호 path가 차단되면 출력된 allow 명령을 사용자가 명시 확인한 경우에만 실행한다.
4. secret 파일 내용은 직접 읽거나 요약하지 않는다.
