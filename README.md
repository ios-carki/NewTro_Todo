<p align="center">
    <img width="908" alt="스크린샷 2023-01-09 오전 5 31 32" src="https://user-images.githubusercontent.com/44957712/211586794-f92697b6-872d-4f9f-9683-edf213162800.png">
</p>  

***

<p align="center">
<img width="1137" alt="스크린샷 2022-12-17 오후 1 15 34" src="https://user-images.githubusercontent.com/44957712/208224375-06213fc4-b612-4650-a4e6-f3f9843fbc51.png">
</p>

***

# 📱 About Project
**Realm DB를 활용**하여 사용자 **Todo 데이터의 영속성을 유지**시키고, App Depth를 낮추어 **하나의 뷰 안에서 사용자 Todo DB CRUD가 가능**한 **자체 제작 도트아트 테마 기반의 UI를 활용한 Todo앱**입니다. 

부가적인 기능으로는 하루마다 간단한 메모를 작성할 수 있는 **퀵메모,** 달력을 통한 **날짜이동**과 선택한 날짜에 작성된 **Todo 개수 확인**, **Todo 중요도에 따른 텍스트 컬러 변환**, **Todo 완료 및 미루기**, **영어 대응**, **로컬 노티**, **사용자 Todo 데이터 초기화**가 있습니다.

**앱 다운로드 최소 버전은 iOS 15 이상**이며, 해당 버전을 채택한 이유로는 App Store에서 처리한 결과에 의하면 2022년 5월 31일을 기준으로 **82%의 기기에서 iOS 15를 사용중**이기 때문에 해당 버전을 최소 버전으로 채택했습니다.


# 🔨Tech
Architecture - MVC 

Framework - Foundation / UIKit / UserNotification

Library - Realm / Firebase / IQKeyboardManager / SnapKit / Toast / FSCalendar 



# 📲 App Image (v_ 1.2.4)
<p align="center">
    <img width="886" alt="스크린샷 2022-12-17 오후 1 18 58" src="https://user-images.githubusercontent.com/44957712/208224482-16cbcdb1-1750-44fb-b9f1-1861dcfad3e6.png">
    <img width="886" alt="스크린샷 2022-12-17 오후 1 21 45" src="https://user-images.githubusercontent.com/44957712/208224574-87de7c39-f682-40da-81b1-7d39d610b4ed.png">
</p>

# 👤 유저 리뷰
<p align="center">
<img width="816" alt="스크린샷 2022-12-20 오후 8 49 04" src="https://user-images.githubusercontent.com/44957712/208660110-41b91bae-84a8-4ecc-9f96-9a90e1a3d724.png">
</p>

# 🧭 개발 공수
<p align="center">

<img width="851" alt="스크린샷 2023-01-11 오전 12 11 29" src="https://user-images.githubusercontent.com/44957712/211588508-f854148a-2e48-4173-91e2-c8def7a3aac5.png">

</p>

***

# 🔴 Trouble Shooting
### 이슈

앱 사용자 디바이스의 설정상 국가, 지역이 대한민국이 아닐 시, dateFormatter의 Locale identifier를 한국으로 제한했었던 이전 버전코드에서 Crash가 발생했습니다.

### 문제인식

Todo를 작성하기 위해서 Todo버튼의 .TouchUpInside 매서드로 인해 Todo의 contents가 Realm DB에 Add가 되는데, Todo 테이블의 Attribute중 하나인 regDate(등록시간, 날짜)가 대한민국을 제외한 국가의 시간데이터를 받아오지 못하는 이슈에 의한 Crash로 문제인식을 했습니다.

### 해결

dateFormatter locale.current로 사용자가 선택한 디바이스 지역속성 사용

- 관련 내용 블로그 포스팅
    
    [앱 출시 회고](https://carki.tistory.com/37)
    
    [데이터 포맷](https://carki.tistory.com/40)
    

---

# 🤔 프로젝트 회고

앱 출시 고려사항 (HIG, 리젝사유)에 대한 경험과 학습 내용을 프로젝트에 구현하는 과정을 통해 러닝커브가 급격하게 상승했습니다.

- **SnapKit**을 이용한 **Code Base UI.**
- **Realm**을 활용하여 DataBase **스키마 설계에 대한 이해, 유저 데이터 영속성, PK값을 활용한 렘 데이터 중복 방지, 마이그레이션을 통한 스키마 변동사항 대응**을 처리.
- **LocalNotification을 통해** **알림 권한 상태에 따른 분기처리**와, **앱 생명주기에 따른 로컬 노티 메시지 분기**를 구현.
- 다양한 국가에서 서비스하기 위한 **Localizing** 구현.
- **Enum**과 **Property Wrapper**를 통해 **App Theme(Color/ImageSet) 구조화.**

# 💻 NewTro_Todo 앱 출시 Man-Month

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
|[2022.09.22](#2022-09-22)||||
|[2022.09.23](#2022-09-23)|중간발표|||
|[2022.09.24](#2022-09-24)|백업 복구 구현<br/>설정뷰 변경<br/>TODO 완료버튼추가<br/>||[복구관련에러](#복구에러)|[변경 설정뷰](https://user-images.githubusercontent.com/44957712/191313969-9860c9a0-5d11-4d0f-88f5-d43285487ad6.png)<br/>[TODO 완료버튼](#할일-완료여부)<br/>
|[2022.09.25](#2022-09-25)| |||
|[2022.09.26](#2022-09-26)| |||
|[2022.09.27](#2022-09-27)|ToDo셀 드래그 위치에러..|||
|[2022.09.28](#2022-09-28)| ||링크 이미지 참고|[2022.09.28](#2022-09-28)
***

# 📝 Daily Scrum

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
컬러셋, 다국어대응 미리하기 <br/>

### 2022 09 22
- 값전달(1. 클로져 값전달, 2. 델리게이트 값전달, 3. 노티


### 2022 09 23 
= 중간 발표 <br/>
### 2022 09 24
### 복구에러
복구 완료 시점 후 Realm데이터가 존재하는 MainView로 이동하면 화면 멈춤 후 다음 에러 등장 <br/><br/>
<img width="700" alt="스크린샷 2022-09-25 오후 4 24 16" src="https://user-images.githubusercontent.com/44957712/192132830-bc92d3e4-4b92-4598-a844-bf01eb3f7bb8.png"><br/><br/>
에러가 발생하는 조건: 복구시 데이터 정보와 복구 전 데이터 정보가 서로 다를때(복구전 데이터와 복구 후 데이터가 같으면 에러발생 X)<br/><br/>
### 할일 완료여부


https://user-images.githubusercontent.com/44957712/192133589-a24272b9-dfc7-4dff-b981-51e51275ef83.mov


<br/>

### 2022 09 25

### 2022 09 26

### 2022 09 27

MainViewController -> func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) 메서드 내 주석 참고
<br/>
셀의 순서 변화를 감지하기위한 여러 로직을 구현했으나 지금 당장 수정 후 구현이 어렵다고 판단하여 기능 보류

### 2022 09 28

<img width="855" alt="스크린샷 2022-09-28 오후 5 50 51" src="https://user-images.githubusercontent.com/44957712/192734630-ce719c0e-6e80-4f37-a768-c6ba46f6ad66.png">
