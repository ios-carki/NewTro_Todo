//
//  MainViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/09.
//

import Foundation
import UIKit

import RealmSwift

class MainViewController: BaseViewController {
    
    let mainView = MainView()
    let cellDetailCustomView = CustomMenuPopupView()
    let cellDetailCustomVC = CustomMenuPopupViewController()
    
    
    //MARK: -
    var calendar = Calendar.current
    
    //날짜계산을 위한 데이트변수
    var pickedNowDate = Date()
    //데이트포맷 다 바꾸기
    let dateFormatter = DateFormatter()
    
    
    //MARK: -
    static var addTableCell: [String] = []
    
    let localRealm = try! Realm()
    var id: ObjectId?
    var tasks: Results<Todo>! {
        didSet {
            mainView.tableView.reloadSections(IndexSet(0...0), with: .automatic)
            print("데이터 변함!")
        }
    }
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //MARK: -- Print
        print("Realm is located at:", localRealm.configuration.fileURL!)
        //MARK: -- Print
        view.backgroundColor = .mainBackGroundColor
        navigationSetting()
        tableSetting()
        quickNoteTapGesture()
        fetchRealm()
        
        mainView.rightButton.addTarget(self, action: #selector(tomorrowFunc), for: .touchUpInside)
        mainView.leftButton.addTarget(self, action: #selector(yesterdayFunc), for: .touchUpInside)
        
        //셀 삭제 노티
        NotificationCenter.default.addObserver(
          self,
          selector: #selector(self.didDismissDetailNotification(_:)),
          name: NSNotification.Name("DismissDetailView"),
          object: nil
        )
        
    }
    
    @objc func didDismissDetailNotification(_ notification: Notification) {
          DispatchQueue.main.async {
              self.mainView.tableView.reloadData()
          }
    }
    
    //날자 바꿀때마다 실행되어야 되니
    //처음 실행은 오늘날짜라 하더라도
    //날짜를 이동 - 해당 날짜
    //다른 뷰를 갔다와도 날짜유지
    func fetchRealm() {
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        
        //MARK: -- 날짜 변경에따른 테이블 뷰 갱신을위해 이부분 바꿔줌
        //변경 - > let convertDate = dateFormatter.string(from: nowDate)
        let convertDate = dateFormatter.string(from: pickedNowDate)
        tasks = localRealm.objects(Todo.self).sorted(byKeyPath: "regDate", ascending: true).where {
            $0.stringDate == convertDate
        }//.sorted(byKeyPath: "", ascending: <#T##Bool#>)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //테이블뷰의 키보드가 셀을 가릴때
        //keyboardObserver()
        
        
        fetchRealm()
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mainBackGroundColor]
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //키보드 끝나면 없앰
        //keyboardObserverRemove()
    }
    
    func navigationSetting() {
        let calendarButton = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .plain, target: self, action: #selector(calendarButtonClicked))
        let menuButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal"), style: .plain, target: self, action: #selector(menuButtonClicked))
        
        title = "메인"
        navigationController?.navigationBar.backgroundColor = .mainBackGroundColor
        navigationItem.leftBarButtonItem = calendarButton
        navigationItem.leftBarButtonItem?.tintColor = .orange
        
        navigationItem.rightBarButtonItem = menuButton
        navigationItem.rightBarButtonItem?.tintColor = .orange
    }
    
    func tableSetting() {
        mainView.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identifier) as? MainTableViewCell
        mainView.tableView.register(TablePlusCell.self, forCellReuseIdentifier: TablePlusCell.identifier) as? TablePlusCell
        
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        
        //셀 Drag &  Drop
        mainView.tableView.dragInteractionEnabled = true
        mainView.tableView.dragDelegate = self
        mainView.tableView.dropDelegate = self
    }
    
    func quickNoteTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(quickNote))
        mainView.quickNoteView.addGestureRecognizer(tapGesture)
    }
    
    //퀵노트
    @objc func quickNote() {
        //옵셔널 id값을 선언하고 퀵노트가 만들어지면 id값 전달
        var noteID: ObjectId?
        let vc = CustomNotePopupViewController()
        let subVC = CalendarViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .overCurrentContext
        
        subVC.dateCompletionHandler = {
            self.pickedNowDate = subVC.selectedDate
        }
    
        let strPickedNowDate = dateFormatter.string(from: pickedNowDate)
        vc.nowDate = pickedNowDate
        vc.receivedStrDate = strPickedNowDate
        
        //
        let isExisistedText = localRealm.objects(QuickNote.self).where {
            $0.stringToRegDate == strPickedNowDate
        }
        
        if isExisistedText.count == 0 {
            let task = QuickNote(note: "", regDate: pickedNowDate, stringToRegDate: strPickedNowDate, isWrited: false)

            try! localRealm.write({
                localRealm.add(task)
            })
            self.present(nav, animated: false)
        } else {
            self.present(nav, animated: false)
        }
        
    }
    
    @objc func calendarButtonClicked() {
        let vc = CalendarViewController()
        let nav = UINavigationController(rootViewController: vc)
        
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        //방법1
        vc.dateCompletionHandler = {
            self.pickedNowDate = vc.selectedDate
            let convertDate = self.dateFormatter.string(from: vc.selectedDate)
            print("전달된 데이트: ", convertDate)
            self.mainView.datePickBtn.setTitle(convertDate, for: .normal)
            self.fetchRealm()
            self.mainView.tableView.reloadData()
        }
        self.present(nav, animated: true)
    }
    
    @objc func menuButtonClicked() {
        let vc = SettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    //MARK: -- cell dateCalculation
    func dayCalculation(formula: String) -> Date { // 월 별 일 수 계산
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let result: Date?
        
        if formula == "plus" {
            result = calendar.date(byAdding: .day, value: 1,to: pickedNowDate)!
            print("+계산된 날짜", result)
            pickedNowDate = result!
            
            let formattedPickedDate = dateFormatter.string(from: pickedNowDate)
            mainView.datePickBtn.setTitle(formattedPickedDate, for: .normal)
            
            //**
            mainView.tableView.reloadData()
            
            //MARK: - 리턴값 result로 바궈도 같은지 확인
            return pickedNowDate
        } else {
            //값 전달을 pick가 아니라 계산된 값을 전달
            result = calendar.date(byAdding: .day, value: -1,to: pickedNowDate)!
            print("-계산된 날짜", result)
            pickedNowDate = result!
            
            let formattedPickedDate = dateFormatter.string(from: pickedNowDate)
            mainView.datePickBtn.setTitle(formattedPickedDate, for: .normal)
            
            //**
            mainView.tableView.reloadData()
            
            return pickedNowDate
        }
        
    }
    
    @objc func yesterdayFunc() {
        dayCalculation(formula: "minus")
        fetchRealm()
    }
    
    @objc func tomorrowFunc() {
        dayCalculation(formula: "plus")
        fetchRealm()
    }
    
}

//MARK: -- TableView
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    //MARK: -- Cell DetailButtonEvent(VC:CustomMenuPopupViewController)
    //MARK: --공부하기(버튼에 대한 태그전달)
    //check
    @objc func menuPopupButtonClicked(btnName: UIButton) {
        let nav = UINavigationController(rootViewController: cellDetailCustomVC)
        
        //같은방식
        //cellDetailCustomView.setImportanceButton.addTarget(self, action: #selector(cellDetailCustomVC.importanceButtonClicked), for: .touchUpInside)
        //
        
        nav.modalPresentationStyle = .overCurrentContext
        cellDetailCustomVC.receivedTag = btnName.tag
        cellDetailCustomVC.tasks = self.tasks
        
        self.present(nav, animated: false)
    }
    //MARK: --공부하기(버튼에 대한 태그전달)
    
    @objc func completeButtonClicked(btnName: UIButton) {
        
        if tasks[btnName.tag].isFinished == false {
            try! self.localRealm.write {
                tasks[btnName.tag].isFinished = true
            }
        } else {
            try! self.localRealm.write {
                tasks[btnName.tag].isFinished = false
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    //섹션의 셀 개수니까
    //섹션 0 - 추가버튼 눌리면 1개씩 추가
    //섹션 1 - 고정(플러스버튼)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tasks.count
            
        } else if section == 1 {
            return 1
        }
        return tasks.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch indexPath.section {
        case 0:
            
            //셀 생성 시점에 클로저로 전달
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
            
            cell.todoTextField.text = tasks[indexPath.row].todo!
            //셀 생성 시점에 id도 전달함
            cell.id = tasks[indexPath.row].objectID
            
            //셀 버튼에 tag값을 부여(셀 순서대로)
            //만약 버튼의 태그값과
//            for i in 0..<tasks.count {
//                cell.importanceSelectBtn.tag = i
//            }
//            cellDetailCustomVC.receivedTag = cell.importanceSelectBtn.tag
//            cellDetailCustomVC.id = tasks[cell.importanceSelectBtn.tag].objectID
            //MARK: --공부하기(버튼에 대한 태그전달)
            
            cell.importanceSelectBtn.tag = indexPath.row //상세설정
            cell.completeTodoBtn.tag = indexPath.row //완료버튼
            cell.importanceSelectBtn.addTarget(self, action: #selector(menuPopupButtonClicked), for: .touchUpInside)
            cell.completeTodoBtn.addTarget(self, action: #selector(completeButtonClicked), for: .touchUpInside)
            
            
            //MARK: --공부하기(버튼에 대한 태그전달)
            
            //fetchRealm()
            
            print("전달id값(cellDetailCustomVC.id)", cellDetailCustomVC.receivedTag)
            print("전달id값(tasks[indexPath.row].objectID)", tasks[cell.importanceSelectBtn.tag].objectID)
            
            cell.backgroundColor = .systemCyan
            
            cell.selectionStyle = .none
            return cell
        case 1:
            let plusCell = tableView.dequeueReusableCell(withIdentifier: TablePlusCell.identifier, for: indexPath) as! TablePlusCell
            plusCell.receivedNowDate = pickedNowDate
            print("pickedNowDate", pickedNowDate)
            
            //타입지정에 값을 대입
            plusCell.reloadCell = {
//                tableView.reloadSections(IndexSet(0...0), with: .automatic)
                tableView.reloadData()
            }
            
            tableView.reloadSections(IndexSet(0...0), with: .automatic)
            plusCell.backgroundColor = .systemCyan
            
            plusCell.selectionStyle = .none
            return plusCell
        default:
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "cel", for: indexPath)
            return cell1
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 60
        } else if indexPath.section == 1 {
            return 70
        }
        
        return 50
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        /*
         1 -> regdate
         2 -> regdate
         1의 데이터가 2의 데이트

         작성을 2가 먼저했다고
         뒤에 1이 작선된거임

         그럼 레그데이트만 바꾸면 되지않을까
         그러고 나서 원래 1번 데이터상에서도 레그데이터가 바껴야되고
         그러고 정렬시키면
         */
        
//        =================😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡=================
//        print("\(sourceIndexPath.row) -> \(destinationIndexPath.row)")
//        print("함수호출", #function)
//        
//        var temp: Date?
//        var temp1: Date?
//        
//        var dateArr: [Date] = []
//        
//        dateArr = localRealm.objects(Todo.self).map {
//            $0.regDate
//        }
//        
//        let moveCell = dateArr[sourceIndexPath.row]
//        dateArr.remove(at: sourceIndexPath.row)
//        dateArr.insert(moveCell, at: destinationIndexPath.row)
//        
//        print(dateArr)
//        
//        //tasks에 직접 변경
//        //처음 몇번은 바뀜
//        //뒤에 테이블 추가가 되긴하는데 뷰에 그려지지가 않음
//        temp = tasks[sourceIndexPath.row].regDate
//        temp1 = tasks[destinationIndexPath.row].regDate
////        tasks[sourceIndexPath.row].regDate = temp1!
////        tasks[destinationIndexPath.row].regDate = temp!
//        
//        try! localRealm.write {
//            localRealm.create(Todo.self, value: ["objectID": tasks[sourceIndexPath.row].objectID, "regDate": temp1], update: .modified)
//            localRealm.create(Todo.self, value: ["objectID": tasks[destinationIndexPath.row].objectID, "regDate": temp], update: .modified)
////            fetchRealm()
//        }
//        mainView.tableView.reloadData()
//
//        print("무빙", start)
//        print("데스티네이션", end)
        
//        //tasks에 직접 변경
//        temp = tasks[sourceIndexPath.row].regDate
//        temp1 = tasks[destinationIndexPath.row].regDate
//        tasks[sourceIndexPath.row].regDate = temp1!
//        tasks[destinationIndexPath.row].regDate = temp!
        
//        dateArr.forEach { swap in
//            try! localRealm.write {
//                localRealm.add(swap)//Todo(value: ["objectID": swap.objectID, "regDate": swap.regDate]), update: .modified)
//            }
//
//        }
        
        
        
//        =================😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡😡=================
        
        //움직이려는 셀
//        var start = localRealm.objects(Todo.self).where {
//            $0.regDate == tasks[sourceIndexPath.row].regDate
//        }

        //떨어진위치의 셀
//        var end = localRealm.objects(Todo.self).where {
//            $0.regDate == tasks[destinationIndexPath.row].regDate
//        }
        
//        var temp3: Results<Todo>?
        
        //데이터 교환
        //        temp3 = start
        //        start = end
        //        end = temp3!
        // start -> end
        // end -> start
        //로 바뀌게 됨
    
        //소스 인덱스를 start의 regDate
//        try! localRealm.write {
//            sourceToUpdate.regDate = start[0].regDate
//        }
        //데스티네이션 인덱스를 end로 해봤는데
        //데이터가 안바뀌고 처음 바뀐 Date로만 계속 바껴서 나중에는 Date가 다 똑같아짐(똑같아져서 인덱스 오류 안남)
//        try! localRealm.write {
//            destiToUpdate.regDate = temp![0].regDate
//        }
//        mainView.tableView.reloadData()
//        try! self.localRealm.write {
//            print("destinationCell[0].regDate", start[0].regDate)
//            print("movingCell[0].regDate", end[0].regDate)
//            localRealm.create(Todo.self, value: ["objectID": tasks[sourceIndexPath.row].objectID, "regDate": end[0].regDate], update: .modified)
//            localRealm.create(Todo.self, value: ["objectID": tasks[destinationIndexPath.row].objectID, "regDate": start[0].regDate], update: .modified)
//            mainView.tableView.reloadData()
//
//
//        }
        
        
        print(tasks[0])
    }
}


extension MainViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
            return [UIDragItem(itemProvider: NSItemProvider())]
        }
}

extension MainViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if session.localDragSession != nil {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) { }
}



//extension MainViewController {
//    func keyboardObserver() {
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    func keyboardObserverRemove() {
//            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
//            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
//        }
//
//        @objc func keyboardShow(notification: NSNotification) {
//            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
////            self.view.frame.origin.y -=
////            self.view.frame.origin.y = 0 - keyboardSize.height
////            self.mainView.bottomView.frame.origin.y = 0 - keyboardSize.height
//            self.mainView.bottomView.snp.remakeConstraints { make in
//                make.top.equalTo(mainView.safeAreaLayoutGuide)
//                make.leading.equalTo(mainView.safeAreaLayoutGuide).offset(20)
//                make.trailing.equalTo(mainView.safeAreaLayoutGuide).offset(-20)
//                make.bottom.equalTo(mainView.mainBackgroundImage.snp.top).offset(keyboardSize.height)
//            }
//        }
//
//        @objc func keyboardHide(notification: NSNotification) {
////            self.constraint.constant += 100
////            self.view.frame.origin.y = 0
////            self.mainView.bottomView.frame.origin.y = 0
//            self.mainView.bottomView.snp.remakeConstraints { make in
//                make.top.equalTo(mainView.todoView.snp.bottom).offset(8)
//                make.leading.equalTo(mainView.safeAreaLayoutGuide).offset(20)
//                make.trailing.equalTo(mainView.safeAreaLayoutGuide).offset(-20)
//                make.bottom.equalTo(mainView.mainBackgroundImage.snp.top)
//            }
//        }
//}
//
