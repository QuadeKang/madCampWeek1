
![title](https://github.com/QuadeKang/madCampWeek1/assets/124063721/749a516b-58dd-410b-9087-f404e688a1cf)

[![Version](https://badge.fury.io/gh/tterb%2FHyde.svg)](https://github.com/QuadeKang/madCampWeek1/raw/main/bizLink.apk)

---
**Week1. 4분반 최우정, 강정환**
- 업무와 일상의 연락처를 분리하세요. 그럼에도 상상할 수 있는 모든 기능을 앱에서 제공합니다.
- 다른 사람의 명함을 사진으로 보관 가능합니다. 명함을 자르고, 돌리고, 명함 크기에 맞게 저장하세요.
- 내 명함을, 다른 사람의 명함을 QR코드 공유를 통해 빠르게 교환할 수 있습니다.


---
### A. 개발 팀원
- **최우정** KAIST 화학과 21학번
- **강정환** 부산대학교 컴퓨터공학 18학번

---
### B. 개발환경
<img src="https://img.shields.io/badge/Dart-0175C2?style=flat-round&logo=dart&logoColor=white"/> <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-round&logo=flutter&logoColor=white"/> <img src="https://img.shields.io/badge/Android-34A853?style=flat-round&logo=android&logoColor=white"/> <img src="https://img.shields.io/badge/Android Studio-3DDC84?style=flat-round&logo=androidstudio&logoColor=white"/>

- Language : Dart (3.2.3 )
- Framework : Flutter (3.16.5)
- OS : Android
- IDE : Android Studio
- Target Device : Galaxy s10e 

  > minSdkVersion 20
  > 
  > targetSdkVersion 31


---
### C. 의존성
|LIB|Ver|Use|
|-|-|-|
|[cupertino_icons](https://pub.dev/packages/cupertino_icons)|1.0.2|This is an asset repo containing the default set of icon assets used by Flutter's Cupertino widgets.|
|[image_picker](https://pub.dev/packages/image_picker)|1.0.5|A Flutter plugin for iOS and Android for picking images from the image library, and taking new pictures with the camera.|
|[path_provider](https://pub.dev/packages/path_provider)|2.1.1|A Flutter plugin for finding commonly used locations on the filesystem.|
|[path](https://pub.dev/packages/path)|1.8.3|A comprehensive, cross-platform path manipulation library for Dart.|
|[image_cropper](https://pub.dev/packages/image_cropper)|5.0.1|A Flutter plugin for Android, iOS and Web supports cropping images.|
|[url_launcher](https://pub.dev/packages/url_launcher)|6.2.2|A Flutter plugin for launching a URL.|
|[contacts_service](https://pub.dev/packages/contacts_service)|0.6.3|A Flutter plugin to access and manage the device's contacts.|
|[permission_handler](https://pub.dev/packages/permission_handler)|11.1.0|This plugin provides a cross-platform (iOS, Android) API to request permissions and check their status.|
|[shared_preferences](https://pub.dev/packages/shared_preferences)|2.2.2|Wraps platform-specific persistent storage for simple data.|
|[qr_flutter](https://pub.dev/packages/qr_flutter)|4.0.0|QR.Flutter is a Flutter library for simple and fast QR code rendering via a Widget or custom painter.|
|[qr_code_scanner](https://pub.dev/packages/qr_code_scanner)|1.0.1|A QR code scanner that works on both iOS and Android by natively embedding the platform view within Flutter.|
|[flutter_svg](https://pub.dev/packages/flutter_svg)|2.0.9|Draw SVG files using Flutter.|

---
### D. 어플리케이션 소개
#### 0. Intro

<img src='https://github.com/QuadeKang/madCampWeek1/assets/124063721/3e05b534-4c43-4d67-9491-e915bcbf6121' width="200" height="400" />

***Major Features***
- 기업용 연락처 관리 도구에 적합한 로고 디자인이 적용되어 있습니다.
- 어플이 실행준비 되고 있다는 것을 알려주기 위한 애니메이션이 존재합니다.
---

***기술 설명***
- 애니메이션 구현을 위하여 AnimationController를 활용하였습니다.
- 애니메이션에 생동감을 더하기 위해 [Cubic](https://cubic-bezier.com/#.17,.67,.83,.67)을 사용하여 키프레임 가속도를 조절하였습니다.
---


#### 1. Tab 1
![Tab1_확장](https://github.com/QuadeKang/madCampWeek1/assets/124063721/7cfb27fa-b9fe-4b5d-901d-9bd1f8046a7c)
![Tab1_기능연결](https://github.com/QuadeKang/madCampWeek1/assets/124063721/b91c563b-1431-4610-abbe-123c0e5c2248)
![Tab1_연락처저장](https://github.com/QuadeKang/madCampWeek1/assets/124063721/2112f6be-3662-4395-a167-fe66c59c991d)



***Major Features***
- 연락처를 추가/삭제/수정 할 수 있습니다.
- 연락처를 내장 주소록 앱에서 불러올 수 있습니다.
- 연락처에는 이름/전화번호/조직/직급/이메일/메모/사진 의 정보를 넣을 수 있습니다.
- 전화/문자/이메일이 내장 앱과 연결되어 있습니다.
- 이름/전화번호/이메일/조직/직급/메모의 정보를 바탕으로 주소록 검색이 가능합니다.
- 필수 정보인 이름/전화번호/조직/직급/이메일을 입력하지 않으면 경고 메시지가 뜨고, 저장이 제한됩니다.
---

***기술 설명***
- shared_preference를 통해 앱을 키-값 쌍으로 연결해 연락처 정보를 저장/수정 했습니다.
- url_launcher를 통해 schema를 각각 'tel', 'sms', 'mailto'&'intent' 기능을 사용하여 전화/문자/메일 기능을 연결합니다. 
- contacts_service를 통해 내부 저장소에 있는 연락처를 불러옵니다.
- AndroidManifest.xml 파일에 uses-permission을 추가하여 권한을 설정합니다.
- expanded된 경우 trailing을 제거하고, _buildExpandedCard를 통해 확장된 카드위젯을 추가합니다.
- 연락처는 이름을 기반으로 정렬합니다.
- 검색어를 소문자로 변환하고, 이름/전화번호/조직/소속/이메일/메모 전부를 소문자로 변환하여 검색 쿼리를 수행합니다.
---


#### 2. Tab 2
![Tab2_스크롤](https://github.com/QuadeKang/madCampWeek1/assets/124063721/950da0a3-b257-4c2f-8099-3034c129bb27)
![Tab2_사진수정](https://github.com/QuadeKang/madCampWeek1/assets/124063721/306670b0-13fd-4f9e-9b24-a765fdffd9e5)
![Tab2_드래그](https://github.com/QuadeKang/madCampWeek1/assets/124063721/58e938d9-ef52-4c07-865f-00c6d4cfed0a)


***Major Features***
- 명함 사진을 목록을 보여줍니다.
- 사진은 명함 비율에 맞춰 9:5 비율로 제공됩니다.
- 비율에 맞지 않는 사진은 사진을 선택하여 설정된 비율로 크롭 및 회전할 수 있습니다.
- 사진을 촬영하거나 기존 갤러리에서 사진을 가져와서 추가할 수 있습니다.
- 저장된 명함을 삭제할 수 있습니다.
- Drag&Drop 방식으로 명함의 순서를 변경할 수 있습니다.
---

***기술 설명***
- fileModificationTimes를 활용하여 가장 최근에 수정한 파일을 최상단에 위치시킵니다.
- ImagePicker.pickImage(source: ImageSource.camera)를 통해 사진을 촬영하고 앱 저장소에 저장 후 사진 목록에 포함하여 레이아웃을 업데이트 합니다.
- ImagePicker.pickMultiImage()를 통해 내장저장소에 있는 파일을 앱 저장소로 가져옵니다.
- ImageCropper를 사용하여 9:5비율 크롭 및 회전이 가능한 포토 에디터를 제공합니다.
- ListView.builder 내부에 GeustureDetector를 사용하여 사진 선택 기능을 구현했습니다.
- ReorderableListView를 사용하여 Drag&Drop 기능을 구현하였습니다.
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
- [RepaintBoundary](https://api.flutter.dev/flutter/widgets/RepaintBoundary-class.html)를 통해 레이아웃을 캡쳐할 수 있는 기능을 제작했습니다.
- QrImage를 통해 명함 정보가 담긴 QR코드를 생성합니다.
- QRView를 통해 QR코드를 읽을 수 있는 카메라를 실행합니다.
- QR코드를 인식한 순간, 카메라를 멈추어 함수가 여러번 호출되는 것을 예방합니다.
---

### E. 별도 기술 소개

#### 1. findPath
- path_provider를 통해 앱 내에서 사용하는 저장소 폴더 위치를 반환해주는 함수를 포함하고 있습니다.
#### 2. contactManager
- shared_preference를 통해 주소록을 저장하고 불러오는 함수를 포함하고 있습니다.
#### 3. customDialog
- 예/아니오 이지선다의 AlertDialog의 디자인 프리셋이 포함되어 있습니다.
#### 4. colors
- 앱에서 사용하는 컬러셋을 저장해 두었습니다.

| Color Name     | Color Block | Color Name     | Color Block |
|----------------|:-----------:|----------------|:-----------:|
| backgroundGray | ![backgroundGray](https://via.placeholder.com/20/ECECEC/000000?text=+) | icongray       | ![icongray](https://via.placeholder.com/20/7C7C7C/FFFFFF?text=+) |
| gray           | ![gray](https://via.placeholder.com/20/979797/000000?text=+) | iconred        | ![iconred](https://via.placeholder.com/20/D62727/FFFFFF?text=+) |
| primaryBlue    | ![primaryBlue](https://via.placeholder.com/20/476BEC/000000?text=+) | icongreen      | ![icongreen](https://via.placeholder.com/20/12A763/FFFFFF?text=+) |
| iconskyblue    | ![iconskyblue](https://via.placeholder.com/20/32A0EB/FFFFFF?text=+) | white          | ![white](https://via.placeholder.com/20/FFFFFF/000000?text=+) |

  
### F.Build File
<나중에 추가>
