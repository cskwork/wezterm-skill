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

## 자주 만나는 함정

### 1. 새 탭이 즉시 죽음 — `fish: No such file or directory` (macOS)

`config/launch.lua`가 macOS의 default shell을 `/opt/homebrew/bin/fish`로 하드코딩합니다. fish가 없으면 새 탭이 ENOENT로 즉사하고, `exit_behavior="CloseOnCleanExit"` 때문에 에러 메시지가 박힌 채 탭이 안 닫혀요.

수정 (zsh 사용자):

```lua
-- config/launch.lua
elseif platform.is_mac then
   options.default_prog = { '/bin/zsh', '-l' }
   options.launch_menu = {
      { label = 'Zsh', args = { '/bin/zsh', '-l' } },
      { label = 'Bash', args = { '/bin/bash', '-l' } },
      { label = 'Fish', args = { '/opt/homebrew/bin/fish', '-l' } },     -- 설치 후 복귀
      { label = 'Nushell', args = { '/opt/homebrew/bin/nu', '-l' } },    -- 설치 후 복귀
   }
```

또는 `default_prog = {}`로 두면 WezTerm이 `/etc/passwd`에서 사용자 로그인 셸을 자동 선택합니다.

### 2. retro 탭 바에는 클릭 가능한 X 닫기 버튼이 없음

KevinSilvester는 `use_fancy_tab_bar = false`로 retro 탭 바를 씁니다. 이 모드는 마우스로 탭을 닫는 native 위젯을 제공하지 않아요. 옵션:

- **그대로 사용**: `Cmd+W` (탭) / leader+`x` (패인) 키보드 단축키
- **fancy 전환**: `config/appearance.lua`에서 `use_fancy_tab_bar = true` — hover 시 우상단 ✕ 버튼 자동 표시. catppuccin 색은 `colors/custom.lua`의 `tab_bar` 섹션에 이미 매핑되어 있어 색 손실 없음. 단, 양 끝 반원 글리프(`scircle_left/right`)가 fancy 탭의 둥근 모양 안에 겹쳐 보일 수 있어요.

### 3. 배경 이미지 폴더 미존재

`utils/backdrops.lua`가 `~/Pictures/Wallpapers/`를 스캔합니다. 없으면 조용히 빈 배경 — leader+`b`/`Shift+B`/`/` 키도 무해하게 무시됩니다.

## 되돌리기

```bash
# 백업 폴더로 교체
rm -rf ~/.config/wezterm
mv ~/.config/wezterm.bak-* ~/.config/wezterm  # 가장 최근 백업 폴더 선택
```
