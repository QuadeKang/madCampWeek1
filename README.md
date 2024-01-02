# BizLink
## 비즈링크에 관한 1줄 설명하면 됩니다.

---
Week1. 4분반 최우정, 강정환
- 설명
- 설명
- 설명

---
### a. 개발 팀원
- **최우정** KAIST 화학과 21학번
- **강정환** 부산대학교 컴퓨터공학 18학번

---
### b. 개발환경
<img src="https://img.shields.io/badge/Dart-0175C2?style=flat-round&logo=dart&logoColor=white"/> <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-round&logo=flutter&logoColor=white"/> <img src="https://img.shields.io/badge/Android-34A853?style=flat-round&logo=android&logoColor=white"/> <img src="https://img.shields.io/badge/Android Studio-3DDC84?style=flat-round&logo=androidstudio&logoColor=white"/>

- Language : Dart
- Framework : Flutter
- OS : Android
- IDE : Android Studio
- Target Device : Galaxy s10e, Galaxy Note20

---
### c. 의존성
|LIB|Ver|
|-|-|
|cupertino_icons|1.0.2|
|image_picker|1.0.5|
|path_provider|2.1.1|
|path|1.8.3|
|image_cropper|5.0.1|
|url_launcher|6.2.2|
|contacts_service|0.6.3|
|permission_handler|11.1.0|
|nfc_manager|3.3.0
|shared_preferences|2.2.2
|qr_flutter|4.0.0
|qr_code_scanner|1.0.1|
|flutter_svg|2.0.9|

---
### d. 어플리케이션 소개
#### 0. Intro
<사진 넣기>  

***Major Features***
- 기업용 연락처 관리 도구에 적합한 로고 디자인이 적용되어 있습니다.
- 어플이 실행준비 되고 있다는 것을 알려주기 위한 애니메이션이 존재합니다.
---

***기술 설명***
- 애니메이션 구현을 위하여 AnimationController를 활용하였습니다.
- 애니메이션에 생동감을 더하기 위해 Cubic을 사용하여 키프레임 가속도를 조절하였습니다.
---


#### 1. Tab 1
<사진 넣기>  

***Major Features***
- 연락처를 추가/삭제/수정 할 수 있습니다.
- 연락처는 이름/전화번호/조직/직급/이메일/메모/사진 의 정보를 넣을 수 있습니다.
- 전화/문자/이메일 에 대하여 내장 앱에 연결되어 있습니다.
- 이름/전화번호/이메일/조직/직급/메모의 정보를 바탕으로 주소록 검색이 가능합니다.
---

***기술 설명***
- shared_preference
- 전화/문자/메일 앱 연결
- 연락처 불러오기
- 권한 설정
- expended -> 리스트뷰
- 정렬, 전체검색
---


#### 2. Tab 2
<사진 넣기>  
*Major Features*
- 명함 사진을 목록을 보여줍니다.
- 사진은 명함 비율에 맞춰 9:5 비율로 제공됩니다.
- 비율에 맞지 않는 사진은 사진을 선택하여 설정된 비율로 크롭 및 회전할 수 있습니다.
- 사진을 촬영하거나 기존 갤러리에서 사진을 가져와서 추가할 수 있습니다.
- 저장된 명함을 삭제할 수 있습니다.
- // Drag&Drop 방식으로 명함의 순서를 변경할 수 있습니다.
---

***기술 설명***
- fileModificationTimes를 활용하여 가장 최근에 수정한 파일을 최상단에 위치시킵니다.
- ImagePicker.pickImage(source: ImageSource.camera)를 통해 사진을 촬영하고 앱 저장소에 저장 후 사진 목록에 포함하여 레이아웃을 업데이트 합니다.
- ImagePicker.pickMultiImage()를 통해 내장저장소에 있는 파일을 앱 저장소로 가져옵니다.
- ImageCropper를 사용하여 9:5비율 크롭 및 회전이 가능한 포토 에디터를 제공합니다.
- ListView.builder 내부에 GeustureDetector를 사용하여 사진 선택 기능을 구현했습니다.
- // Drag&Drop 구현 기술 작성성
---


#### 3. Tab 3
<사진 넣기>  

***Major Features***
- 사용자가 설정한 정보를 바탕으로 명함을 생성합니다.
- 공유 버튼을 눌러서 명함을 공유할 수 있는 고유 QR Code가 생성됩니다.
- 다운로드 버튼을 눌러서 상대방의 명함을 받을 수 있는 QR Code Reader가 실행됩니다.
- 명함을 성공적으로 읽으면, 상대방의 명함 카드를 저장할 수 있습니다.
- 명함 카드를 기반으로 상대방의 연락처를 저장하고 Tab 1의 주소록에 연동할 수 있습니다.

---

***기술 설명***
- RepaintBoundary를 통해 레이아웃을 캡쳐할 수 있는 기능을 제작했습니다.
- QrImage를 통해 명함 정보가 담긴 QR코드를 생성합니다.
- QRView를 통해 QR코드를 읽을 수 있는 카메라를 실행합니다.
- QR코드를 인식한 순간, 카메라를 멈추어 함수가 여러번 호출되는 것을 예방합니다.
---

### e. 별도 기술 소개

#### 1. findPath
#### 2. contactManager



  
