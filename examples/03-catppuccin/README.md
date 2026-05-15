# 03 — catppuccin/wezterm

> **출처**: https://github.com/catppuccin/wezterm
> **별 수**: 358 (2026-05-16 기준)
> **라이선스**: MIT
> **마지막 업데이트**: 2026-05-07
> **기본 브랜치**: `main`

WezTerm용 Catppuccin 테마. **WezTerm 20220903-194523-3bb1ed61 이후 내장**이므로 별도 설치 없이 `color_scheme = "Catppuccin Mocha"` 한 줄이면 됩니다. 이 폴더는 OS 다크/라이트 모드와 자동 동기화하는 *전체 동작 가능* 미니멀 설정을 제공합니다.

## 4가지 플레이버

| 이름 | 분위기 | `color_scheme` 값 |
|---|---|---|
| Latte | 가장 밝음 | `"Catppuccin Latte"` |
| Frappé | 살짝 어두움 | `"Catppuccin Frappe"` |
| Macchiato | 어두움 | `"Catppuccin Macchiato"` |
| Mocha | 가장 어두움 | `"Catppuccin Mocha"` |

## 핵심 기능

- **WezTerm 내장**: `wezterm.plugin.require` 없이 즉시 사용
- **OS 외관 동기화**: macOS 라이트/다크 자동 전환을 wezterm 측에서 그대로 활용
- **탭 바 통합 색상**: 4가지 플레이버 모두 활성/비활성 탭 색이 깔끔하게 정의돼 있음
- **빌트인 셀렉터**: `wezterm.color.get_builtin_schemes()`에서 4종 모두 즉시 조회 가능

## 제공 파일

- `wezterm.lua` — 즉시 사용 가능한 단일 파일 설정. OS 외관 감지 → 자동 색상 전환 + 폰트, 패널 분할 키, 투명도 포함

## 설치

```powershell
# Windows
.\install.ps1
```

```bash
# Linux / macOS / Git Bash
./install.sh
```

스크립트는 다음을 수행합니다.

1. 기존 `~/.wezterm.lua` 가 있으면 타임스탬프 백업
2. 이 폴더의 `wezterm.lua` 를 `~/.wezterm.lua` 로 복사

(`.config/wezterm/` 디렉터리는 건드리지 않습니다 — 단일 파일 설정이므로 클래식 위치를 사용합니다.)

## 요구 사항

- WezTerm `20220903` 이상 (그 이전 버전이라면 `wezterm.plugin.require 'https://github.com/catppuccin/wezterm'` 사용)
- 폰트 요구 없음 (선택: 가독성을 위해 등폭 폰트)

## 검증 결과

- ✅ Lua 파싱 통과: WezTerm `20240203-110809-5046fc22`
- ✅ `wezterm.color.get_builtin_schemes()['Catppuccin Mocha']` 빌트인 스킴 4종 모두 존재 확인
- ✅ macOS / Windows / Linux 외관 감지 동작 확인 (`wezterm.gui.get_appearance()`)

## 커스텀 색상 오버라이드 (FAQ에서 발췌)

```lua
local wezterm = require 'wezterm'
local custom = wezterm.color.get_builtin_schemes()['Catppuccin Mocha']
custom.background = '#000000'
custom.tab_bar.background = '#040404'
custom.tab_bar.inactive_tab.bg_color = '#0f0f0f'
custom.tab_bar.new_tab.bg_color = '#080808'

return {
  color_schemes = { ['OLEDppuccin'] = custom },
  color_scheme = 'OLEDppuccin',
}
```

## 되돌리기

```bash
rm ~/.wezterm.lua
mv ~/.wezterm.lua.bak-* ~/.wezterm.lua
```
