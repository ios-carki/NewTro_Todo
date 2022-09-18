# NewTro_Todo 앱 출시 TIL

|일자|내용|새로 알게된 내용|어려웠던 점|이미지 링크
|----------|--------------------|--------------------|--------------------|----------
|2022.09.06|페이지 뷰 완성|도트 제작 사이트||[페이지뷰](https://user-images.githubusercontent.com/44957712/190864376-28b88f4e-c7e5-42fc-af4b-14552e2733c8.png)
|2022.09.07|메인 UI / 바버튼 UI|||
|2022.09.08 ~ 2022.09.09|설정뷰 UI|||[설정뷰](https://user-images.githubusercontent.com/44957712/190864934-2f8be7e6-4ef5-436d-bc69-d6b7ecaaa580.png)
|2022.09.11 ~ 2022.09.12|설정뷰 데이터복구 얼럿|||[데이터복구 얼럿](https://user-images.githubusercontent.com/44957712/190864944-5dba850e-1c15-4a76-bd28-59f37b671931.png)
|2022.09.13|중복코드 줄이기 <br/>- Extension 활용|||[달력뷰](https://user-images.githubusercontent.com/44957712/190865252-6c8db32e-0c61-4fbd-a6ff-83c624d4e298.png)
|2022.09.14|메인 UI수정|세그먼트 컨트롤러 라이브러리||
|2022.09.15|메인 UI 커스텀 셀|일정 즐겨찾기 등록시 보관함으로<br/>들어가는 애니메이션 구상|컬렉션<br/>컬렉션, 테이블뷰 분기처리<br/>갱신|
|2022.09.16|메인뷰 컬렉션뷰 삭제<br/>테이블뷰 단독 사용으로 변경||셀 추가 버튼 기능구현<br/>테이블뷰 갱신시점<br/>Realm CRUD|[변경 메인뷰](https://user-images.githubusercontent.com/44957712/190865170-9416c934-5c7f-48cb-9e91-498df667f729.png)
|2022.09.17|Realm 쿼리 로직변경|ID값을 통한 데이터 업데이트|데이터 추가, 변경|

2022.09.18 - 데이터상에 저장된 시간데이터(UTC)를 데이트 포맷 형식에 맞춰서 READ할 수 있는지
            -해결: 동일한 시간의 데이터를 String타입의 컬럼을 추가하는 식으로 해결
            -> 이방법에 대한 잭님의 해결책, 미미하지만 String타입보다는 Int형이 속도차원에서 살짝 빠를 순 있음
