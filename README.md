# VLC Bookmarker Plugin

미디어 재생 중 원하는 곳에 북마크(책갈피)를 추가하고, 나중에 해당 시간으로 바로갈 수 있는 확장(Extension)입니다.
작성된 파일 포맷은 Mac과 Windows 모두 호환됩니다.

## 기능 스크린샷 / 메뉴얼
*   **추가 (Add)**: 현재 재생 중인 위치의 시간을 저장
*   **바로가기 (Jump)**: 리스트에서 선택한 북마크 위치로 재생 지점 이동
*   **이름 덮어쓰기 (Edit)**: 현재 텍스트 박스에 있는 이름으로 선택한 북마크의 이름을 수정
*   **삭제 (Remove)**: 선택한 북마크 삭제

## 설치 방법

### 🍎 Mac
1. `VLC_Bookmarker_v1.0.lua` 파일을 복사합니다.
2. 아래 경로 중 하나를 선택하여 붙여넣습니다. (폴더가 없으면 새로 만드세요)
   *   **추천 (사용자 전용)**: `~/Library/Application Support/org.videolan.vlc/lua/extensions/`
       *   (Finder 열기 -> 이동 -> 폴더로 이동 -> `~/Library/Application Support/org.videolan.vlc` 치고 들어가서 `lua` 폴더 ➡ `extensions` 폴더)
   *   **모든 사용자 공통**: `/Applications/VLC.app/Contents/MacOS/share/lua/extensions/`
       *   (응용 프로그램에서 VLC 우클릭 -> 패키지 내용 보기 -> Contents -> MacOS -> share -> lua -> extensions)

### 🪟 Windows
1. `VLC_Bookmarker_v1.0.lua` 파일을 복사합니다.
2. 폴더 탐색기를 열고 주소창에 `%APPDATA%\vlc\` 를 입력하여 이동합니다.
3. 해당 경로 안에 `lua` 폴더를 만들고, 그 안에 추가로 `extensions` 폴더를 만듭니다. (경로가 `%APPDATA%\vlc\lua\extensions\` 가 되도록)
4. 그 안에 파일을 붙여넣습니다.

## 사용 방법
1. VLC 플레이어를 완전히 껐다가 다시 켭니다.
2. 상단 메뉴에서 플러그인을 실행합니다.
   *   **현재 Mac:** 메뉴 바 ➡️ `VLC` ➡️ `Extensions` ➡️ `VLC Bookmarker` 클릭
   *   **현재 Windows:** 상단 탭 ➡️ `보기 (View)` ➡️ 하단 메뉴 중 `VLC Bookmarker` 클릭
3. 미디어 영상을 재생하면서 시간과 이름을 입력하여 북마크를 관리할 수 있습니다!
