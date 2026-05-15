# 02 — QianSong1/wezterm-config

> **출처**: https://github.com/QianSong1/wezterm-config
> **별 수**: 258 (2026-05-16 기준)
> **라이선스**: MIT
> **마지막 업데이트**: 2026-05-15
> **기본 브랜치**: `main`
> **원작자**: KevinSilvester/wezterm-config 의 단순화 포크

KevinSilvester의 구조를 그대로 빌리되 GPU 어댑터/배경 이미지 등 무거운 모듈을 제거해 *모듈식이지만 가벼운* 출발점으로 만든 설정. 중국어 사용자 커뮤니티에서 가장 많이 포크되는 템플릿 중 하나입니다.

## 핵심 기능

- KevinSilvester와 동일한 `config/`, `events/`, `utils/` 디렉터리 구조
- 더 간결한 `events/` (배경 이미지·새 탭 버튼·우측 상태표시줄·탭 타이틀만)
- 기본 색상: Catppuccin Macchiato
- 기본 폰트: `JetBrainsMono NF` (Nerd Font v3.2.1 정확히 일치 필요)
- Windows 우클릭 메뉴 "Open Wezterm Here" 레지스트리 가이드 포함(README 참조)

## 주요 키바인딩

| 키 | 동작 |
|---|---|
| `Ctrl+Shift+C` / `Ctrl+Shift+V` | 복사 / 붙여넣기 |
| `Ctrl+Shift+R` | 탭 이름 변경 |
| `Ctrl+Alt+\` | 가로(좌우) 패널 분할 |
| `Ctrl+Alt+/` | 세로(상하) 패널 분할 |
| `Ctrl+Alt+-` | 현재 패널 닫기 |
| `Ctrl+Alt+Z` | 패널 최대화/복원 |
| `F11` | 전체 화면 |
| `Ctrl+Alt+화살표` | 패널 크기 조정 |
| `Alt+↑` / `Alt+↓` | 폰트 확대/축소 |
| `Alt+R` | 폰트 크기 리셋 |

## 설치

```powershell
# Windows
.\install.ps1
```

```bash
# Linux / macOS / Git Bash
./install.sh
```

기존 `~/.wezterm.lua` / `~/.config/wezterm/` 은 타임스탬프 백업으로 옮겨집니다.

## 요구 사항

- WezTerm `20240127` 이상
- `MesloLGM Nerd Font` 또는 `JetBrainsMono NF` v3.2.1
  - 버전이 어긋나면 아이콘이 깨질 수 있음(원본 README 경고)

## 검증 결과

- ✅ Lua 파싱 통과: WezTerm `20240203-110809-5046fc22`
- ✅ `wezterm --config-file <wrap.lua> ls-fonts --text x` 런타임 에러 없음
- ⚠️ `JetBrainsMono NF` 미설치 시 fallback 경고만 발생

## KevinSilvester 대비 어떤 걸 빼고 어떤 걸 더했나

| 항목 | KevinSilvester | QianSong1 |
|---|---|---|
| 배경 이미지 셀렉터 | ✅ | ❌ 제거 |
| GPU 어댑터 셀렉터 | ✅ | ❌ 제거 |
| 워크스페이스 런처 | ✅ | ❌ 제거 |
| 모듈식 구조 | ✅ | ✅ 동일 유지 |
| Windows 우클릭 메뉴 | ❌ | ✅ README 가이드 추가 |
| README 언어 | 영어 | 중국어 + 영어 혼합 |

## 되돌리기

```bash
rm -rf ~/.config/wezterm
mv ~/.config/wezterm.bak-* ~/.config/wezterm
```
