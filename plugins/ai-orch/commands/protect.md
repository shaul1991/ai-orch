---
description: AI Orch secret/critical file 접근 보호 정책 확인 및 local 허용 관리
argument-hint: "list | check-read <path> | check-write <path> | allow-read <path> | allow-write <path> | revoke <path>"
allowed-tools: [Bash, Read]
---

# AI Orch Protect

Arguments: `$ARGUMENTS`

## Flow

This command delegates to:

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" protect $ARGUMENTS
```

## Instructions

1. secret/critical file 접근 보호 정책을 확인하거나 local user-confirmed allow를 관리한다고 설명한다.
2. repository root에서 `"${CLAUDE_PLUGIN_ROOT}/scripts/ai-orch.sh" protect $ARGUMENTS`를 실행한다.
3. 보호 path가 차단되면 출력된 allow 명령을 사용자가 명시 확인한 경우에만 실행한다.
4. secret 파일 내용은 직접 읽거나 요약하지 않는다.
