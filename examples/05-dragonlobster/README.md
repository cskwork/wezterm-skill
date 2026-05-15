# 05 — dragonlobster/wezterm-config

> **출처**: https://github.com/dragonlobster/wezterm-config
> **별 수**: 68 (2026-05-16 기준)
> **라이선스**: **명시되지 않음** ("All rights reserved" 로 간주)
> **마지막 업데이트**: 2026-05-06
> **기본 브랜치**: `main`
> **저자 의도**: YouTube 영상에서 소개한 "starter template" — 자신만의 설정으로 발전시키도록 의도된 출발점

단일 파일(약 340줄) tmux 스타일 wezterm 설정. 멀티파일 구조의 복잡함 없이 *리더 키 + 패널 + 탭 + 상태 표시* 만 깔끔하게 잡고 싶을 때 베스트.

## 핵심 기능

- **단일 파일**: `wezterm.lua` 하나만 두면 끝 — `require` 없음
- **리더 키 인디케이터**: 리더 활성 시 좌측 상태 표시줄에 🌊 아이콘과 화살표 표시
- **둥근 vs 사각 탭**: `local tab_style = "rounded"` / `"square"` 한 줄로 전환
- **고FPS 옵션**: `config.max_fps = 240`, `animation_fps = 240`
- **Catppuccin Macchiato** 기본 + 탭 바 색상 직접 매핑
- **윈도우 테두리 커스텀**: `window_frame` 의 좌/우/상/하 두께·색을 별도 지정

## 키바인딩 (LEADER = `Alt+q`, 타임아웃 2초)

| 키 | 동작 |
|---|---|
| `LEADER c` | 새 탭 (현재 도메인) |
| `LEADER x` | 현재 패널 닫기 (확인 프롬프트) |
| `LEADER b` / `LEADER n` | 이전 / 다음 탭 |
| `LEADER 0..9` | 해당 인덱스의 탭으로 이동 (0-based) |
| `LEADER \|` | 가로 분할 (좌우) |
| `LEADER -` | 세로 분할 (상하) |
| `LEADER h/j/k/l` | 패널 이동 (vim) |
| `LEADER ←/→/↑/↓` | 5셀씩 패널 크기 조정 |

## 설치

```powershell
# Windows
.\install.ps1
```

```bash
# Linux / macOS / Git Bash
./install.sh
```

스크립트는 **upstream에서 직접 fetch** 합니다 (이 폴더에는 코드 사본을 두지 않음 — 라이선스 미명시 저장소이므로 재배포하지 않음).

1. 기존 `~/.wezterm.lua` 가 있으면 타임스탬프 백업
2. `https://raw.githubusercontent.com/dragonlobster/wezterm-config/main/wezterm.lua` 를 `~/.wezterm.lua` 로 직접 다운로드

## 요구 사항

- WezTerm `20240127` 이상
- 폰트: Maple Mono NF 또는 JetBrains Mono NL (둘 다 없으면 fallback 으로 동작)

## 검증 결과

- ✅ Lua 파싱 통과: WezTerm `20240203-110809-5046fc22`
- ✅ `wezterm --config-file <file> ls-fonts --text "test"` 런타임 에러 없음
- ⚠️ Maple Mono NF 미설치 시 fallback 경고만 발생

## 라이선스 미명시에 대한 안내

이 저장소에는 LICENSE 파일이 없습니다. 기본 저작권법상 **명시적 라이선스가 없으면 모든 권리가 작성자에게 귀속**됩니다.

- ✅ 개인 머신에서 다운로드해서 사용하는 것은 일반적으로 허용 (사용 의도가 명확한 starter template)
- ❌ 그대로 또는 일부 수정해 **재배포·포크 공개·기업 배포** 는 작성자 허락이 필요
- ✅ *영감만 받아 직접 다시 작성* 은 라이선스 무관

따라서 이 폴더의 `install.*` 은 코드 사본을 두지 않고 upstream URL에서 직접 가져옵니다.

## 되돌리기

```bash
rm ~/.wezterm.lua
mv ~/.wezterm.lua.bak-* ~/.wezterm.lua
```
