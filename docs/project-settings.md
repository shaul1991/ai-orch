# Project Settings

## 기본 언어

이 프로젝트의 주 사용 언어는 한글이다.

- 사용자에게 보여주는 설명, 계획, 리뷰, 문서 초안은 기본적으로 한글로 작성한다.
- 코드 식별자, 명령어, 파일 경로, API 이름, 외부 문서의 고유 명칭은 원문을 유지한다.
- 사용자가 명시적으로 요청하거나 대상 프로젝트의 규칙이 필요한 경우에만 다른 언어를 사용한다.

## 기본 AI 역할 분담

기본 역할 분담은 다음과 같다.

| 작업 유형 | 기본 담당 | 기본 provider/model |
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

## 변경 가능성

위 역할 분담은 기본값이며, 사용자는 작업마다 변경할 수 있다.

일회성 변경 예시:

```bash
AI_CODE_PROVIDER=codex-acp AI_CODE_MODEL=gpt-5.5 scripts/sdd-implement.sh sample-feature
AI_DOC_PROVIDER=claude-code AI_DOC_MODEL=default scripts/sdd-docs.sh "topic" docs/output.md
```

장기 변경이 필요하면 `scripts/sdd-*.sh`의 기본 provider/model 값을 바꾸거나, goose 전역 설정을 변경한다.

## 실행 원칙

- 문서/리서치 작업은 source code를 수정하지 않는다.
- 아키텍처 설계와 구현 계획은 요구사항과 acceptance criteria의 승인 범위 안에서만 작성한다.
- Claude Code가 코드 작업을 담당하더라도 도메인/비즈니스 판단은 사람이 한다.
- Codex가 문서와 리서치를 담당하더라도 새로운 정책이나 요구사항을 임의로 확정하지 않는다.
