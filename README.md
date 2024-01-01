# bizLink
---
비즈링크에 관현 1줄 설명
===
Week1 4분반 최우정, 강정환팀
- 

### a. 개발 팀원
- 최우정 KAIST 화학과 21학번
  강정환 부산대학교 컴퓨터공학 18학번
===
### b. 개발환경
- Language : Dart
- Framework : Flutter
- OS : Android
- IDE : Android Studio
- Target Device : Galaxy s10e, Galaxy Note20

### c. 의존성
- cupertino_icons: ^1.0.2
- image_picker: ^1.0.5
- path_provider: ^2.1.1
- path: ^1.8.3
- image_cropper: ^5.0.1
- url_launcher: ^6.2.2
- contacts_service: ^0.6.3
- permission_handler: ^11.1.0
- nfc_manager: ^3.3.0
- shared_preferences: ^2.2.2
- qr_flutter: 4.0.0
- qr_code_scanner: ^1.0.1
- flutter_svg: ^2.0.9
===
### d. 어플리케이션 소개
#### 0. Intro
*Major Features*
- 기업용 연락처 관리 도구에 적합한 로고 디자인이 적용되어 있습니다.
- 어플이 실행준비 되고 있다는 것을 알려주기 위한 애니메이션이 존재합니다.
===
*기술 설명*
- 애니메이션 구현을 위하여 AnimationController를 활용하였습니다.
- 애니메이션에 생동감을 더하기 위해 Cubic을 사용하여 움직임 속도에 대한 곡선을 형성했습니다.
===
#### 1. Tab 1
<사진 넣기>
*Major Features*
- 연락처를 추가/삭제/수정 할 수 있습니다.
- 연락처는 이름/전화번호/조직/직급/이메일/메모/사진 의 정보를 넣을 수 있습니다.
- 전화/문자/이메일 에 대하여 내장 앱에 연결되어 있습니다.
- 이름/전화번호/이메일/조직/직급/메모의 정보를 바탕으로 주소록 검색이 가능합니다.
===
*기술 설명*
-
===
#### 2. Tab 2
<사진 넣기>
*Major Features*
- 명함 사진을 목록을 보여줍니다.
- 사진은 명함 비율에 맞춰 9:5 비율로 제공됩니다.
- 비율에 맞지 않는 사진은 사진을 선택하여 설정된 비율로 크롭 및 회전할 수 있습니다.
- 사진을 촬영하거나 기존 갤러리에서 사진을 가져와서 추가할 수 있습니다.
- 저장된 명함을 삭제할 수 있습니다.
===
*기술 설명*
-
===
#### 3. Tab 3
<사진 넣기>
*Major Features*
- 사용자가 설정한 정보를 바탕으로 명함을 생성합니다.
- 공유 버튼을 눌러서 명함을 공유할 수 있는 고유 QR Code가 생성됩니다.
- 다운로드 버튼을 눌러서 상대방의 명함을 받을 수 있는 QR Code Reader가 실행됩니다.
- 명함을 성공적으로 읽으면, 상대방의 명함 카드를 저장할 수 있습니다.
- 명함 카드를 기반으로 상대방의 연락처를 저장하고 Tab 1의 주소록에 연동할 수 있습니다.
===
*기술 설명*
-
===

  
