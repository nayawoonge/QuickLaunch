<p align="center">
  <img src="Support/AppIcon.png" width="128" alt="QuickLaunch 아이콘">
</p>

<h1 align="center">QuickLaunch</h1>

<p align="center">macOS에서 전역 단축키로 앱을 바로 실행하는 가벼운 유틸리티.</p>

<p align="center">
  <a href="README.md">English</a> | <b>한국어</b>
</p>

---

- 🔑 앱마다 원하는 단축키 지정 (예: `⌥⌘T` → 터미널) — 접근성 권한 불필요 (Carbon HotKey API)
- 🚀 로그인 시 자동 실행 옵션
- 👻 메뉴 막대(상단) 아이콘 숨기기 옵션
- 🫥 Dock(하단) 아이콘 숨기기 옵션
- 🌐 한국어 / English 자동 지원 (시스템 언어 따름)

## 스크린샷


<p align="center">
  <img src="docs/screenshot-main.png" width="540" alt="메인 창">
</p>
<p align="center">
  <img src="docs/screenshot-add.png" width="440" alt="단축키 추가">
</p>


## 설치

### 다운로드 (권장)

1. [Releases](../../releases)에서 최신 `QuickLaunch.dmg` 다운로드
2. DMG를 열고 **QuickLaunch**를 **Applications** 폴더로 드래그
3. 첫 실행 시: 공증되지 않은 앱이므로 **우클릭 → 열기**, 또는 터미널에서:
   ```bash
   xattr -dr com.apple.quarantine /Applications/QuickLaunch.app
   ```

### 소스에서 빌드

macOS 14+, Xcode 또는 Command Line Tools (Swift 5.9+) 필요.

```bash
git clone https://github.com/nayawoonge/QuickLaunch.git
cd QuickLaunch
make install   # 빌드 후 /Applications에 설치
# 또는:
make dmg       # build/QuickLaunch.dmg 생성
```

## 사용법

1. QuickLaunch 실행 → **추가(+)** 버튼 클릭
2. 앱 선택 후 **클릭하여 입력** 버튼을 누르고 원하는 키 조합 입력 (예: `⌥⌘T`)
3. 저장하면 어느 앱에서든 해당 단축키로 앱이 실행/활성화됩니다

### 옵션

| 옵션 | 설명 |
|---|---|
| 로그인 시 자동 실행 | macOS 로그인 시 QuickLaunch 자동 시작 (`SMAppService`) |
| 메뉴 막대에 아이콘 표시 | 끄면 상단 메뉴 막대 아이콘이 사라집니다 |
| Dock 아이콘 숨기기 | 켜면 하단 Dock과 `⌘⇥` 앱 전환기에 나타나지 않습니다 |

> **둘 다 숨겼을 때**: QuickLaunch를 한 번 더 실행하세요 (Spotlight → QuickLaunch). 이미 실행 중인 인스턴스의 설정 창이 다시 열립니다.

### 참고

- 단축키는 최소 1개의 보조키(⌘⌥⌃⇧)가 필요합니다. F1~F20 키는 단독 사용 가능.
- 시스템이나 다른 앱이 선점한 단축키는 등록되지 않으며 목록에 ⚠️ 로 표시됩니다.
- 로그인 항목 등록이 실패하면 앱을 `/Applications`로 옮긴 뒤 다시 시도하세요.

## 라이선스

[MIT](LICENSE)
