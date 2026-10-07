<p align="center">
  <img src="Support/AppIcon.png" width="128" alt="QuickLaunch 아이콘">
</p>

<h1 align="center">QuickLaunch</h1>

<p align="center">macOS에서 전역 단축키로 앱을 바로 실행하는 가벼운 유틸리티.</p>

<p align="center">
  <a href="README.md">English</a> | <b>한국어</b>
</p>

---

- 🔑 앱마다 원하는 단축키 지정 (예: `⌥⌘T` → 터미널) — 기본 실행은 손쉬운 사용 권한 불필요 (Carbon HotKey API)
- 🪟 실행 중인 앱을 앞으로 가져오기 및 선택적 최소화 창 복원
- 🌐 YouTube, YouTube Music 등 설치된 브라우저 웹 앱 지원
- 🚀 로그인 시 자동 실행 옵션
- 👻 메뉴 막대(상단) 아이콘 숨기기 옵션
- 🫥 Dock(하단) 아이콘 숨기기 옵션
- 🌐 한국어 / English 자동 지원 (시스템 언어 따름)

## 미배포 변경 사항 (소스 빌드)

- 지원하는 원격 데스크탑·가상머신 앱을 사용하는 동안 QuickLaunch 단축키 등록을 자동 해제하고, 다른 앱으로 전환하면 복구합니다. 기본값은 켜짐이며 설정에서 끌 수 있습니다.
- 다른 원격 앱을 쓰거나 충돌 원인을 확인할 수 있도록 설정과 메뉴 막대에 단축키 수동 일시정지를 추가했습니다.

## v1.0.3 변경 사항

- 앱 선택 목록에 Finder가 표시됩니다.
- Finder 단축키가 새 창을 만들 수 있는 다시 열기 요청 대신 기존 창을 활성화합니다.
- 시스템의 Finder 검색 단축키 대신 `⌥⌘Space`를 사용하는 설정 안내를 추가했습니다.

자세한 내용은 [영문·한국어 릴리스 노트](docs/releases/v1.0.3.md), 다음 버전 배포 방법은 [릴리스 작성 가이드](docs/releases/README.md)를 참고하세요.

## 스크린샷


<p align="center">
  <img src="docs/screenshot-main.png" width="540" alt="메인 창">
</p>
<p align="center">
  <img src="docs/screenshot-add.png" width="440" alt="단축키 추가">
</p>


## 설치

### 다운로드 (권장)

1. [**QuickLaunch.dmg**](https://github.com/nayawoonge/QuickLaunch/releases/latest/download/QuickLaunch.dmg) 다운로드 (또는 [Releases](../../releases)에서 선택)
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

Command Line Tools의 macOS 27 SDK에서 `SwiftUIMacros` 플러그인을 찾지 못하면 전체 Xcode를 사용하거나, macOS 26.5 SDK가 설치되어 있을 때 다음처럼 빌드할 수 있습니다.

```bash
make app SWIFT_BUILD_FLAGS="--build-system native --sdk /Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk"
```

전체 테스트(`swift test`)는 전체 Xcode처럼 XCTest를 포함하는 도구가 필요합니다.

## 사용법

1. QuickLaunch 실행 → **추가(+)** 버튼 클릭
2. 앱 선택 후 **클릭하여 입력** 버튼을 누르고 원하는 키 조합 입력 (예: `⌥⌘T`)
3. 저장하면 어느 앱에서든 해당 단축키로 앱이 실행/활성화됩니다

### ⌥⌘Space로 기존 Finder 창 사용하기

1. **시스템 설정 → 키보드 → 키보드 단축키 → Spotlight**에서 **Finder 검색 윈도우 보기**(⌥⌘Space)를 끄세요. 기본 단축키는 Finder 검색 창을 여는 기능입니다. [Apple 단축키 안내](https://support.apple.com/ko-kr/102650)
2. QuickLaunch에서 **추가(+) → Finder**를 선택하고 **⌥⌘Space**를 입력하세요.
3. 저장하세요. 시스템 설정을 바꾼 뒤에도 ⚠️가 표시되면 QuickLaunch를 재시작하거나 단축키를 편집·저장해 다시 등록하세요.

Finder는 `/System/Library/CoreServices/Finder.app`에서 자동으로 목록에 추가됩니다. 실행 중인 Finder는 기존 창을 유지한 채 활성화합니다. 모두 최소화되어 있으면 **최소화된 창 복원**을 켜고 손쉬운 사용 권한을 허용하세요. 열린 폴더 창이 하나도 없으면 Finder의 데스크탑이 활성화되며, **⌘N**으로 새 창을 열 수 있습니다. 다른 앱은 기존 열기 동작을 유지합니다.

### 옵션

| 옵션 | 설명 |
|---|---|
| 로그인 시 자동 실행 | macOS 로그인 시 QuickLaunch 자동 시작 (`SMAppService`) |
| 메뉴 막대에 아이콘 표시 | 끄면 상단 메뉴 막대 아이콘이 사라집니다 |
| Dock 아이콘 숨기기 | 켜면 하단 Dock과 `⌘⇥` 앱 전환기에 나타나지 않습니다 |
| 원격 데스크탑·가상머신 앱에서 단축키 자동 일시정지 | 기본값 켜짐. Windows App / Microsoft Remote Desktop, Parallels Desktop(Windows·Linux 및 macOS 가상머신 창 포함), VMware Fusion이 활성화되면 QuickLaunch 단축키를 모두 해제합니다. |
| QuickLaunch 단축키 모두 일시정지 | 직접 끄거나 QuickLaunch를 재시작할 때까지 수동 일시정지합니다. 메뉴 막대에서 앱을 직접 실행할 수 있습니다. |
| 최소화된 창 복원 | 열려 있는 창을 앞으로 가져오고, 모두 최소화되어 있으면 하나를 복원합니다. 기본값은 꺼짐이며 손쉬운 사용 권한이 필요합니다. |

> **둘 다 숨겼을 때**: QuickLaunch를 한 번 더 실행하세요 (Spotlight → QuickLaunch). 이미 실행 중인 인스턴스의 설정 창이 다시 열립니다.

### 앱을 실행해도 창이 보이지 않을 때

- **최소화된 창:** QuickLaunch에서 **최소화된 창 복원**을 켜고 **손쉬운 사용 권한 허용…**을 누른 다음, **시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용**에서 QuickLaunch를 허용하세요. QuickLaunch로 돌아와 단축키를 다시 누르면 됩니다. 최소화되지 않은 창을 우선 사용하고, 모든 창이 최소화되어 있으면 하나만 복원합니다. macOS 손쉬운 사용에 창 정보를 제공하지 않는 앱은 복원을 지원하지 않을 수 있습니다. 권한을 거절하거나 해제해도 기본 앱 실행은 동작합니다.
- **다른 데스크탑(Space) 또는 전체 화면의 창:** **시스템 설정 → 데스크탑 및 Dock → Mission Control**에서 **‘응용 프로그램으로 전환할 때, 응용 프로그램에 대해 윈도우가 열려 있는 Space로 전환’**을 켜세요. QuickLaunch는 기존 앱의 활성화를 요청하고, 실제 Space 전환은 macOS가 처리합니다. 창을 현재 데스크탑이나 모니터로 옮기지는 않습니다. [Apple의 Spaces 안내](https://support.apple.com/ko-kr/guide/mac-help/mh14112/mac)도 참고하세요.
- **열린 창이 없는 앱:** 위에서 설명한 실행 중인 Finder를 제외하고 일반적인 앱 열기 요청을 보내며, 새 창 생성 여부는 해당 앱이 결정합니다.

### 원격 데스크탑·가상머신 안에서 단축키가 동작하지 않을 때

QuickLaunch에 등록된 전역 단축키와 같은 조합은 원격 세션까지 전달되지 않을 수 있습니다. **원격 데스크탑·가상머신 앱에서 단축키 자동 일시정지**를 켜면 지원하는 클라이언트가 활성화된 동안 단축키 등록을 해제합니다. 연결 목록이나 제어 센터에서도 적용됩니다. Windows App으로 접속한 Windows 안에서 VMware를 실행하는 경우에도 macOS의 클라이언트를 기준으로 동작합니다.

일시정지 중에는 **앱 전환을 포함한 QuickLaunch 단축키가 모두 동작하지 않습니다.** Dock이나 macOS 앱 전환기로 다른 로컬 앱으로 돌아오면 복구됩니다. 수동 일시정지나 단축키 입력 중인 상태는 유지됩니다. 자동 일시정지에는 손쉬운 사용 권한이 필요하지 않습니다. 다른 원격 클라이언트, 브라우저 원격 세션, 별도의 게스트 앱 실행기는 자동 감지 대상이 아니므로 수동 일시정지를 사용하세요.

게스트의 `Ctrl+Alt+T` 등이 여전히 동작하지 않으면 QuickLaunch를 완전히 종료한 상태와 비교하세요. 이 기능은 RDP·VMware·게스트 OS의 키 전달 설정까지 변경하지는 않습니다.

- **macOS의 Windows App:** **Connections → Keyboard Mode → Scancode**로 바꾸고 게스트 화면에 포커스를 둔 뒤 **Control + 왼쪽 Option + T**를 눌러보세요. 오른쪽 Option은 AltGr로 전달됩니다. IME 입력이 필요하면 Unicode로 되돌려 사용하세요. [Microsoft 키보드 안내](https://learn.microsoft.com/en-us/windows-app/input-keyboard-mouse-touch-pen?tabs=macos)
- **Windows 안의 VMware Workstation:** **Edit → Preferences → Hot Keys**를 확인하세요. `Ctrl+Alt`가 가상머신 입력 해제 조합으로 지정되어 게스트 단축키와 충돌할 수 있습니다. [Broadcom 입력 해제 안내](https://knowledge.broadcom.com/external/article/302740)를 참고하되, 설정 항목은 버전에 따라 다를 수 있습니다.

### 참고

- 단축키는 최소 1개의 보조키(⌘⌥⌃⇧)가 필요합니다. F1~F20 키는 단독 사용 가능.
- 시스템이나 다른 앱이 선점한 단축키는 등록되지 않으며 목록에 ⚠️ 로 표시됩니다.
- 로그인 항목 등록이 실패하면 앱을 `/Applications`로 옮긴 뒤 다시 시도하세요.

## 라이선스

[MIT](LICENSE)
