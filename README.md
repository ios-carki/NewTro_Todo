# NewTro_Todo 앱 출시 TIL

|일자|내용|새로 알게된 내용|어려웠던 점|이미지 링크
|----------|--------------------|--------------------|--------------------|--------------------
|[2022.09.06](#2022-09-06)|페이지 뷰 완성|도트 제작 사이트||[페이지뷰](https://user-images.githubusercontent.com/44957712/190864376-28b88f4e-c7e5-42fc-af4b-14552e2733c8.png)
|[2022.09.07](#2022-09-07)|메인 UI / 바버튼 UI|||
|[2022.09.08 ~ 2022.09.09](#2022-09-08---2022-09-09)|설정뷰 UI|||[설정뷰](https://user-images.githubusercontent.com/44957712/190864934-2f8be7e6-4ef5-436d-bc69-d6b7ecaaa580.png)
|[2022.09.11 ~ 2022.09.12](#2022-09-11-2022-09-12)|설정뷰 데이터복구 얼럿|||[데이터복구 얼럿](https://user-images.githubusercontent.com/44957712/190864944-5dba850e-1c15-4a76-bd28-59f37b671931.png)
|[2022.09.13](#2022-09-13)|중복코드 줄이기 <br/>- Extension 활용|||[달력뷰](https://user-images.githubusercontent.com/44957712/190865252-6c8db32e-0c61-4fbd-a6ff-83c624d4e298.png)
|[2022.09.14](#2022-09-14)|메인 UI수정|세그먼트 컨트롤러 라이브러리||
|[2022.09.15](#2022-09-15)|메인 UI 커스텀 셀|일정 즐겨찾기 등록시 보관함으로<br/>들어가는 애니메이션 구상|컬렉션<br/>컬렉션, 테이블뷰 분기처리<br/>갱신|
|[2022.09.16](#2022-09-16)|메인뷰 컬렉션뷰 삭제<br/>테이블뷰 단독 사용으로 변경||셀 추가 버튼 기능구현<br/>테이블뷰 갱신시점<br/>Realm CRUD|[변경 메인뷰](https://user-images.githubusercontent.com/44957712/190865170-9416c934-5c7f-48cb-9e91-498df667f729.png)
|[2022.09.17](#2022-09-17)|Realm 쿼리 로직변경|ID값을 통한 데이터 업데이트|데이터 추가, 변경|
|[2022.09.18](#2022-09-18)|캘린더뷰(이미지참고)<br/>중요도 배치 고민|String, Int 비교속도|Realm데이터 상 원하는<br/>컬럼만 가져오기|[중요도1](https://user-images.githubusercontent.com/44957712/190911198-dde39e4b-84b0-4245-8050-5471d6910afe.png)<br/>[중요도2](https://user-images.githubusercontent.com/44957712/190912589-24bf0d02-5a2c-4ba9-8eac-f20bd4952924.png)<br/>[중요도3](https://user-images.githubusercontent.com/44957712/190917010-e960f6d5-f076-4414-a131-24f617c2a9c4.png)<br/>[캘린더뷰](https://user-images.githubusercontent.com/44957712/190911363-09dbbbad-ab9e-4e4c-b9cd-d301a75b262f.png)
|[2022.09.19](#2022-09-19)|오늘 날짜에 맞는 메인뷰|원하는 데이터에 맞춰서 데이터 정렬|Date 값전달|[Date값전달 오류](https://user-images.githubusercontent.com/44957712/191014148-01adafd0-bcc1-4f96-bd2f-22a954c804d3.png)
|[2022.09.20](#2022-09-20)|- 앱 테마 컨센 살리기<br/>- 셀 세부설정(이미지 참고)<br/>- 멘토링을 통한<br/>앱 업데이트 방향성||- 셀의 상세뷰 버튼에 대한<br/>인덱스 가져오기|
|[2022.09.21](#2022-09-21)|||[참고](#화면전환시-테이블뷰-리로드)<br/>[버튼tag](#테이블-뷰-셀내에-있는-버튼에-tag부여하기)|[셀 디테일 설정 버튼](https://user-images.githubusercontent.com/44957712/191313969-9860c9a0-5d11-4d0f-88f5-d43285487ad6.png)<br/>[(영상)](https://user-images.githubusercontent.com/44957712/191539036-7cb04975-d4da-46c5-bec2-f0a19b8cc02b.mov)

### 2022 09 06

### 2022 09 07

### 2022 09 08   2022 09 09

### 2022 09 11 2022 09 12

### 2022 09 13

### 2022 09 14

### 2022 09 15

### 2022 09 16

### 2022 09 17

### 2022 09 18
-1. 데이터상에 저장된 시간데이터(UTC)를 데이트 포맷 형식에 맞춰서 READ할 수 있는지<br/>
-해결: 동일한 시간의 데이터를 String타입의 컬럼을 추가하는 식으로 해결<br/>
-> 이방법에 대한 잭님의 피드백: 약간이지만 String타입보다는 Int형이 속도차원에서 살짝 빠를 순 있음<br/>
-> 데이터 테이블에대한 인덱스 값을 부여할 수 있음(수업자료 참고)<br/>

-2. 중요도 1~3중에서 적합한 UI고민중<br/>
-> 도이님: 프로그래스 바 추천<br/>
-> 팀[위즐리]: 버튼클릭한번 -> 상 / 두번 -> 중 / 세번 -> 하 추천<br/>
-> 재훈님 in 팀[위즐리]: UIMenu 추천 [채택]<br/>

### 2022 09 19
-1. 이동된 날짜(메인뷰 - <, > 버튼)에 따른 TablePlusCell의 Date() 변수에 MainViewController의 pickNowDate 값에 대한<br/> 값전달이 제대로 이루어지지 않아서 어려움을 겪음(프로퍼티를 이용한 값전달 사용)

재훈님 - UImenu선택 후 팝업뷰 처럼<br/>
상민님 - 내가 한대로<br/>
윤제님 - 스와이프액션에 포함시키기<br/>
학성님 - 완전 액션에 놓던가, 메뉴에 놓던가 통일시켜라<br/>

### 2022 09 20

### 2022 09 21
#### 테이블 뷰 셀내에 있는 버튼에 tag부여하기<br/><br/>
![스크린샷 2022-09-22 오전 2 08 59](https://user-images.githubusercontent.com/44957712/191568003-20e3be64-ecef-46e6-9881-9a84b2f6b33d.png)
<br/><br/>
버튼 클릭메서드 작성
<br/><br/>
![스크린샷 2022-09-22 오전 2 10 54](https://user-images.githubusercontent.com/44957712/191568373-0cf9f7eb-6fe8-49c4-9493-f1e6a5c59dc4.png)
<br/><br/>
새로 알게된 점:<br/>
1.for문을 돌려서 버튼 하나하나 tag값을 달아주는것이 아닌 cell.{btnName}.tag = indexPath.row 로 작성<br/>
2.버튼 클릭 메서드에 매개변수로 UIButton을 받아오면 인덱스에 해당되는 버튼의 태그값을 불러옴(btnName.tag)<br/>
<br/>

#### 화면전환시 테이블뷰 리로드<br/>
셀에 대한 세부설정 중 셀 삭제기능구현 중 셀을 삭제하면 팝업뷰가 자동으로 dismiss됨<br/>
하지만 dismiss이후에 메인뷰의 테이블뷰가 갱신이 되지않아, 다른뷰로 이동후 다시 돌아오면 그때서야 갱신이 되는문제가 발생함<br/>
테이블 뷰에대한 갱신시점이 문제인가 싶어서 뷰의 라이프사이클, 상세설정뷰의 기능(중요도, 즐겨찾기, 삭제)메서드 내에서 리로드를 해주었지만<br/>
문제가 해결되지 않아서 해결방법을 찾아보기 시작함<br/>
여기서 알게된 것은 바로 NotificationCenter이다.<br/>
커스텀 팝업뷰(상세설정뷰)를 VC1, 메인뷰(dismiss된 이후에 보여지는 메인뷰)를 VC2라고 한다면<br/>
모달이 dismiss될때 NotificationCenter를 보내주려고 한다.<br/><br/>
1. NotificationCenter Post<br/>
VC1의 뷰가 사라지기 전(viewWillDisappear에서 다음과 같은 코드를 작성해주었다)<br/>
<img width="700" alt="스크린샷 2022-09-22 오전 1 49 47" src="https://user-images.githubusercontent.com/44957712/191564429-867ed202-01ef-4676-a1dc-e098d7875298.png">
<br/>
Notification을 보냇으면 이것을 받아오는 과정도 필요하다<br/><br/>
2. NotificationCenter AddObserver<br/>
VC2의 viewDidLoad에 다음과 같은 옵저버를 추가해줬다.(주의: Post시의 노티피케이션 네임과 동일한 이름 작성)<br/><br/>
<img width="700" alt="스크린샷 2022-09-22 오전 1 56 51" src="https://user-images.githubusercontent.com/44957712/191565853-b8bc218f-952e-46fb-97b0-2e0510e47129.png"><br/><br/>
<img width="543" alt="스크린샷 2022-09-22 오전 1 58 47" src="https://user-images.githubusercontent.com/44957712/191566211-c533005a-b30e-45cd-b84a-febdec80d586.png"><br/><br/>

<br/>
컬러셋, 다국어대응 미리하기
