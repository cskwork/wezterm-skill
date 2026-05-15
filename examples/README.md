# WezTerm Starter Templates

다섯 가지 GitHub에서 가장 별이 많이 달린 WezTerm 설정 템플릿을 정리한 폴더입니다. 각 템플릿은 다음을 포함합니다.

- 출처(저장소 URL, 별 수, 라이선스)
- 핵심 기능 요약
- 설치 스크립트(`install.ps1` Windows / `install.sh` Unix·macOS·Git Bash)
- 키바인딩 치트시트
- 이 머신에서 검증한 결과(WezTerm `20240203-110809-5046fc22`)

## 빠른 비교표

| # | 템플릿 | ⭐ | 라이선스 | 구조 | 특징 | 추천 사용처 |
|---|--------|------|---------|------|------|-----------|
| 01 | [KevinSilvester/wezterm-config](https://github.com/KevinSilvester/wezterm-config) | 1072 | MIT | 멀티파일 | 배경 이미지 셀렉터, GPU 어댑터 셀렉터, 모듈식 | 풀스택 개발자, 데스크톱 |
| 02 | [QianSong1/wezterm-config](https://github.com/QianSong1/wezterm-config) | 258 | MIT | 멀티파일 | KevinSilvester 단순화 포크, 깔끔한 기본값 | 가벼운 모듈식 출발점 |
| 03 | [catppuccin/wezterm](https://github.com/catppuccin/wezterm) | 358 | MIT | 단일 파일 | 가장 인기 있는 테마(WezTerm 내장) + OS 다크/라이트 자동 동기화 | 테마 우선 시작 |
| 04 | [sravioli/wezterm](https://github.com/sravioli/wezterm) | 155 | GPL-2.0 | 멀티파일 | 반응형 상태 표시줄, 커맨드 팔레트 보강, 클래스 기반 OOP | 모듈식 OOP 선호자 |
| 05 | [dragonlobster/wezterm-config](https://github.com/dragonlobster/wezterm-config) | 68 | 라이선스 없음 | 단일 파일 | tmux 스타일 리더 키, 둥근/사각 탭, 리더 활성 표시 | 한 파일로 끝내고 싶을 때 |

별 수와 업데이트 시각은 2026-05-16 기준이며 `examples/<dir>/README.md`에 메타데이터 헤더로 박제되어 있습니다. 최신 값은 `gh api repos/<owner>/<repo>`로 확인하세요.

## 검증 방법

설치 없이 각 설정이 파싱·실행되는지 확인하려면:

```bash
# 1. 저장소를 임시 디렉터리로 클론
git clone --depth 1 https://github.com/<owner>/<repo>.git /tmp/wzt

# 2. wrap.lua가 package.path를 보정한 뒤 원본 wezterm.lua를 로드
cat > /tmp/wrap.lua <<'LUA'
local target = os.getenv('WEZTERM_TEST_DIR')
package.path = target .. '/?.lua;' .. target .. '/?/init.lua;' .. package.path
return assert(loadfile(target .. '/wezterm.lua'))()
LUA

# 3. wezterm을 GUI 없이 띄워 설정만 평가
WEZTERM_TEST_DIR=/tmp/wzt wezterm --config-file /tmp/wrap.lua ls-fonts --text x
```

런타임 에러 없이 폰트 정보가 출력되면 통과입니다. `Unable to load a font...` 경고는 Nerd Font 미설치 시 정상이며 fallback으로 동작합니다.

## 설치 전 체크리스트

1. **기존 설정 백업**: 모든 `install.ps1` / `install.sh`은 `~/.wezterm.lua`와 `~/.config/wezterm/`을 타임스탬프 폴더로 옮긴 뒤 새 설정을 배치합니다.
2. **Nerd Font 준비**: 대부분의 템플릿이 JetBrainsMono Nerd Font / MesloLGM Nerd Font / Fira Code Nerd Font 중 하나를 가정합니다. `references/color-schemes.md`와 각 README의 *Required Fonts* 항목을 확인하세요.
3. **WezTerm 버전**: 일부 템플릿은 `nightly`를 요구합니다. 안전한 최소 버전은 `20240127-113634-bbcac864`이지만, `sravioli`는 nightly에서만 모든 기능이 동작합니다.

## 라이선스 주의 사항

- **MIT (01, 02, 03)**: 자유롭게 재배포 가능. `install.*`은 upstream에서 직접 가져오며 로컬 복사본은 두지 않습니다.
- **GPL-2.0 (04)**: 파생 작업물도 GPL을 따라야 합니다. 그대로 사용·수정은 자유이며, `install.*`이 가져온 `LICENSE`를 절대 삭제하지 마세요.
- **라이선스 없음 (05)**: 명시적 라이선스가 없으면 "모든 권리 보유"로 간주됩니다. 개인 사용은 안전하지만 포크·재배포·기업 환경 적용 전에 작성자에게 문의가 필요합니다. 이 폴더는 코드를 복사하지 않고 upstream에서 직접 가져오기만 합니다.
