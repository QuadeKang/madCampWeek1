## 연락처 data_structure

1. 이름
2. 전화번호
3. 소속
4. 직급
5. 메모
6. 사진

{
  name: type(str),
  number: type(str),
  company: type(str),
  position: type(str),
  memo: type(str),
  photo: type(str),
}

포지션의 경우 기본으로 셋팅된 여러 옵션 중에서 쉽게 고를 수 있고, 특수한 포지션의 경우 직접 추가 가능하게.
사진의 경우 링크(type: str)로 연결됨.
