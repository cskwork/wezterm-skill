# 01 — KevinSilvester/wezterm-config

> **출처**: https://github.com/KevinSilvester/wezterm-config
> **별 수**: 1072 (2026-05-16 기준)
> **라이선스**: MIT
> **마지막 업데이트**: 2026-05-15
> **기본 브랜치**: `master`

GitHub에서 가장 별이 많은 단독 WezTerm 설정 저장소. 풀 기능 모듈식 구조로 *Catppuccin 기반 색상 팔레트*, 배경 이미지 사이클링, GPU 어댑터 자동 선택까지 한 번에 제공합니다.

## 핵심 기능

- **모듈식 디렉터리**: `config/`, `events/`, `utils/`, `colors/`, `backdrops/` 로 분리
- **배경 이미지 셀렉터** (`utils/backdrops.lua`)
  - `LEADER + b` → 다음 이미지 순환
  - `LEADER + Shift + b` → 퍼지 검색으로 직접 선택
  - `LEADER + /` → 배경 토글
- **GPU 어댑터 셀렉터** (`utils/gpu_adapter.lua`) — `front_end = 'WebGpu'` 일 때만 활성화. Windows: DX12 > Vulkan > OpenGL, Linux: Vulkan > OpenGL, macOS: Metal 순으로 선호
- **이벤트 기반 상태 표시줄**: 활성 워크스페이스, 시간/날짜, 미확인 탭 인디케이터
- **숫자 배지 탭**: 활성 탭에는 진행 인디케이터(`show_progress`)
- **CI 검증**: 저장소가 GitHub Actions 린트를 통과

## 요구 사항

- WezTerm `20240127-113634-bbcac864` 이상(권장: nightly)
- Nerd Font (JetBrains Mono Nerd Font 권장)
- 배경 이미지를 쓰려면 `$HOME/Pictures/Wallpapers/` 등 이미지 폴더 (기본 경로는 `utils/backdrops.lua`에서 설정)

## 키바인딩 핵심 (LEADER = `Ctrl+a`)

| 키 | 동작 |
|---|---|
| `LEADER \|` / `LEADER -` | 패널 가로/세로 분할 |
| `LEADER h/j/k/l` | 패널 이동 |
| `LEADER Shift+H/J/K/L` | 패널 크기 조정 |
| `LEADER c` / `LEADER x` | 탭 생성 / 패널 닫기 |
| `LEADER b` | 배경 이미지 다음 |
| `LEADER Shift+B` | 배경 이미지 퍼지 검색 |
| `LEADER /` | 배경 이미지 토글 |
| `LEADER w` | 워크스페이스 런처 |

전체 키맵: `config/bindings.lua` 참고.

## 설치

```powershell
# Windows (PowerShell)
.\install.ps1
```

```bash
# Linux / macOS / Git Bash
./install.sh
```

스크립트는 다음을 수행합니다.

1. 기존 `~/.wezterm.lua` 또는 `~/.config/wezterm/` 을 `~/.config/wezterm.bak-YYYYMMDD-HHMMSS/`로 백업
2. 저장소를 `~/.config/wezterm/`에 `git clone --depth 1`
3. 다음 단계 안내(폰트 설치, WezTerm 재시작)

## 검증 결과

- ✅ Lua 파싱 통과: WezTerm `20240203-110809-5046fc22`
- ✅ `wezterm --config-file <wrap.lua> ls-fonts --text x` 런타임 에러 없음
- ⚠️ Nerd Font 미설치 머신에서는 `JetBrainsMono Nerd Font` fallback 경고가 뜨지만 동작에는 영향 없음

## 되돌리기

```bash
# 백업 폴더로 교체
rm -rf ~/.config/wezterm
mv ~/.config/wezterm.bak-* ~/.config/wezterm  # 가장 최근 백업 폴더 선택
```
