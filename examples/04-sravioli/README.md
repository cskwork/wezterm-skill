# 04 — sravioli/wezterm

> **출처**: https://github.com/sravioli/wezterm
> **별 수**: 155 (2026-05-16 기준)
> **라이선스**: GPL-2.0 (코드) / 별도 LICENSE-DOCS (문서·이미지)
> **마지막 업데이트**: 2026-04-21
> **기본 브랜치**: `main`

이탈리아 개발자 sravioli의 정성 들인 모듈식 설정. 다른 템플릿과 달리 **클래스 기반 OOP 스타일** 로 짜여 있고(`utils/class/config.lua`), 화면 너비에 따라 상태표시줄 요소가 단계적으로 줄어드는 *반응형 status bar* 가 시그니처 기능입니다.

## 핵심 기능

- **OOP 빌더**: `Config:new():add(...)` 패턴 — 추가 모듈을 메서드 체인으로 합침
- **반응형 status bar**: 너비가 줄어들면 배터리/날짜/호스트명/CWD 정보가 자동으로 축약
  - Battery: 아이콘+퍼센트 → 퍼센트만 → 아이콘만
  - Datetime: `Thu Aug 1 19:30` → `01/08 19:30` → `19:30`
  - Hostname: 전체 → 첫 글자만
- **커맨드 팔레트 보강** (`events/augment-command-palette.lua`): 자주 쓰는 명령을 팔레트에 추가
- **format-tab-title 이벤트**: 가독성 좋은 탭 표시 (인덱스 + 제목 + 분할 인디케이터)
- **mappings/** 디렉터리: 키 매핑을 영역별로 파일 분리
- **picker/** 디렉터리: 워크스페이스/색상스킴 등 fuzzy picker 모듈

## 요구 사항

- WezTerm **nightly** (안정 버전에서는 일부 기능 미지원)
- 폰트
  - Fira Code Nerd Font
  - Monaspace Radon
  - Monaspace Krypton

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

1. 기존 `~/.wezterm.lua` / `~/.config/wezterm/` 을 타임스탬프 백업
2. `git clone --depth 1 https://github.com/sravioli/wezterm ~/.config/wezterm`
3. **GPL-2.0 LICENSE 와 LICENSE-DOCS 가 함께 클론됨** — 절대 삭제하지 마세요. 파생 작업도 GPL을 따라야 합니다.

## 검증 결과

- ✅ Lua 파싱 통과: WezTerm `20240203-110809-5046fc22`
- ✅ `wezterm --config-file <wrap.lua> ls-fonts --text x` 런타임 에러 없음
- ⚠️ 일부 기능(예: 풀 옵션 status bar)은 nightly에서만 정상 동작

## 디렉터리 한눈에 보기

```
sravioli/wezterm/
├── config/        -- appearance, bindings, fonts, general
├── events/        -- update-status, format-tab-title, augment-command-palette
├── mappings/      -- 기능별 키 매핑
├── picker/        -- 워크스페이스/색상스킴 picker
├── utils/
│   └── class/
│       └── config.lua  -- Config:new(), :add() 빌더
├── wezterm.lua    -- 진입점 (8줄!)
├── LICENSE        -- GPL-2.0
└── LICENSE-DOCS   -- 문서·이미지 별도 라이선스
```

## GPL-2.0 라이선스 주의

- 이 설정을 그대로 또는 수정해 **공개 저장소에 게시할 경우** 파생 저작물도 GPL-2.0 으로 공개해야 합니다.
- 개인 머신에서 비공개로 쓰는 것은 자유입니다.
- 영감만 받아 *새로 작성*하는 것은 GPL 영향권 밖이지만, 코드를 옮겨오면 영향권 안입니다.

## 되돌리기

```bash
rm -rf ~/.config/wezterm
mv ~/.config/wezterm.bak-* ~/.config/wezterm
```
