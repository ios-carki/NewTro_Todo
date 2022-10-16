//
//  SettingViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/12.
//

import Foundation
import UIKit
import MessageUI

import AcknowList
import RealmSwift
import Toast
import Zip


final class SettingViewController: BaseViewController {
    
    let mainView = SettingView()
    let settingMenuList = ["settingMenuList_Theme".localized(), "settingMenuList_ClearData".localized(), "settingMenuList_Contact_Developer".localized(), "settingMenuList_License".localized()]
    let settingImageList = ["paintbrush", "arrow.clockwise", "questionmark.circle", "info.circle"]
    
    let nowVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    
    let localRealm = try! Realm()
    
    override func loadView() {
        self.view = mainView
        
        mainView.versionInfoLabel.text = "loadView_versionInfoLabel_Text".localized() + "\(nowVersion)"//"현재버전: ver \(nowVersion)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        naviSetting()
        tableSetting()
//        fetchDocumentZipFile()
        view.backgroundColor = .mainBackGroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        naviSetting()
        navigationController?.navigationBar.backgroundColor = .mainBackGroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .systemGray6
    }
    
    func naviSetting() {
        title = "NavigationBar_Title_SettingViewController".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    func tableSetting() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingCell")
        
    }
    
    //MARK: -- 백업
    //수업땐 UIViewController 익스텐션으로 관리했음
    //도큐멘트 경로
//    func documentDirectoryPath() -> URL? {
//        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
//
//        return documentDirectory
//    }
//
//    func fetchDocumentZipFile() {
//        do {
//            guard let path = documentDirectoryPath() else { return }
//
//            let docs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
//            print("이게머지👠👠👠👠👠👠👠👠 docs: ", docs)
//
//            let zip = docs.filter {
//                $0.pathExtension == "zip"
//            }
//            print("집 이건 머지👠👠👠👠👠👠 zip: ", zip)
//
//            let result = zip.map {
//                $0.lastPathComponent
//            }
//            print("리절트 이건 뭐지👠👠👠👠 result: ", result)
//        } catch {
//            print("ERROR")
//        }
//    }
//
//    func backupFunction() {
//        var urlPaths = [URL]()
//
//        //도큐먼트 위치에 백업 파일 확인 = 도큐먼트 경로 갖고오기
//        guard let path = documentDirectoryPath() else {
//            self.view.makeToast("도큐먼트 위치에 오류가 있습니다.(백업실패)")
//            return
//        }
//
//        //램 파일 갖고오기
//        let realmFile = path.appendingPathComponent("default.realm") //램 파일이 없는경우 유효성검사 필요
//
//        //램 파일 유효성 검사(있는지 없는지)
//        guard FileManager.default.fileExists(atPath: realmFile.path) else {
//            self.view.makeToast("백업할 파일이 없습니다.")
//            return
//        }
//
//        urlPaths.append(URL(string: realmFile.path)!)
//
//        //백업 파일을 압축: URL파일 만들기
//        //압축 파일을 만들때 사용자가 압축한 시간을 명확하게 표현하기 위해서 압축파일명에 시간대를 추가해주는 작업도 필요할 듯
//        //간단하게 Date()로 하면 되지만 UTC -> Locale화 시켜서 포맷을 해서 붙여주는게 낫다고 판단함
//        do {
//            let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "New_Tro_TODO_1")
//            print("Archive Location: \(zipFilePath)")
//            showActivityViewController()
//        } catch {
//            self.view.makeToast("압축을 실패했습니다.")
//        }
//
//        //ActivityViewController
//    }
//
//    //ActivityViewController띄우는 메서드
//    func showActivityViewController() {
//        //도큐먼트 위치에 백업 파일 확인 = 도큐먼트 경로 갖고오기
//        guard let path = documentDirectoryPath() else {
//            self.view.makeToast("도큐먼트 위치에 오류가 있습니다.(백업실패)")
//            return
//        }
//
//        //램 파일 갖고오기
//        let backupFileURL = path.appendingPathComponent("New_Tro_TODO_1.zip") //램 파일이 없는경우 유효성검사 필요
//
//        let vc = UIActivityViewController(activityItems: [backupFileURL], applicationActivities: [])
//        self.present(vc, animated: true)
//    }
//    //MARK: -- 백업
//
//    //MARK: -- 복구
//
//    func restoreFunction() {
//        let documnetPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.archive], asCopy: true)
//        documnetPicker.delegate = self
//        documnetPicker.allowsMultipleSelection = false //여러개 선택 못하게
//        self.present(documnetPicker, animated: true)
//
//    }
//    //MARK: -- 복구
    
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingMenuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mainView.tableView.dequeueReusableCell(withIdentifier: "settingCell")
        cell?.backgroundColor = .mainBackGroundColor
        cell?.imageView?.image = UIImage(systemName: settingImageList[indexPath.row])
        cell?.imageView?.tintColor = .black
        cell?.textLabel?.font = .mainFont(size: 20)
        cell?.textLabel?.text = settingMenuList[indexPath.row]
        cell?.textLabel?.textColor = .black
        
        switch (indexPath.row) {
        case 0:
            cell?.selectionStyle = .none
            cell?.accessoryType = .disclosureIndicator
        case 1:
            cell?.selectionStyle = .none
            cell?.accessoryType = .disclosureIndicator
        case 2:
            cell?.selectionStyle = .none
            cell?.accessoryType = .disclosureIndicator
        case 3:
            cell?.selectionStyle = .none
            cell?.accessoryType = .disclosureIndicator
        default:
            cell?.selectionStyle = .none
            cell?.accessoryType = .none
        }
        
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = mainView.tableView.dequeueReusableCell(withIdentifier: "settingCell")
        
        switch (indexPath.row) {
        case 0:
            customAlertSimple(title: "Alert_SettingViewController_Theme_CustomAlertSimple_Title".localized(), message: "Alert_SettingViewController_Theme_CustomAlertSimple_Message".localized(), cancelButtonText: "Alert_SettingViewController_Theme_CustomAlertSimple_CancelButtonText".localized())
        case 1:
            let ok = UIAlertAction(title: "Alert_SettingViewController_DataClear_UIAlertAction_OkButton_Title".localized(), style: .default) { action in
                //초기화 처리 구현해야됨
                print("데이터 초기화됨")
                UserDefaults.standard.set(false, forKey: "oldUser")
                
                try! self.localRealm.write {
                    self.localRealm.deleteAll()
                }
                
                let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
                let sceneDelegate = windowScene?.delegate as? SceneDelegate
                let vc = PageViewController()
                let nav = UINavigationController(rootViewController: vc)
                
                sceneDelegate?.window?.rootViewController = nav
                sceneDelegate?.window?.makeKeyAndVisible()
                
                
            }
            self.customAlert(title: "Alert_SettingViewController_DataClear_UIAlertAction_Title".localized(), message: "Alert_SettingViewController_DataClear_UIAlertAction_Message".localized(), style: .alert, actions: ok)
                        
            //UIAction띄워서 3개
//            let backUp = UIAlertAction(title: "데이터 백업", style: .default) { action in
//                self.backupFunction()
//            }
//
//            let restore = UIAlertAction(title: "데이터 복구", style: .default) { action in
//                self.restoreFunction()
////                do {
////                    self.restoreFunction()
////                } catch {
////                    print(error)
////                }
////                let view = DummyView()
////                self.present(view, animated: false)
//            }
//
//            let clearData = UIAlertAction(title: "Alert_SettingViewController_DataClear_UIAlertAction_OkButton_Title".localized(), style: .default) { action in
//                //초기화 처리 구현해야됨
//                print("데이터 초기화됨")
//                UserDefaults.standard.set(false, forKey: "oldUser")
//
//                self.clearRealmData()
//
//                let okAction = UIAlertAction(title: "확인", style: .default) { action in
//                    self.switchToFirstView()
//                }
//                self.customAlertOneButton(alertTitle: "처음으로 돌아갑니다", alertMessage: "", actionTitle: "확인", action: okAction)
//
//            }
//
//            customActionSheet(title: "데이터 백업 / 복구 / 초기화", message: "", actions: backUp, restore, clearData)
            
            //초기화 처리 구현해야되는데 초기화는 신중해야되니 별도의 alert 추가
//            let clearTodo = localRealm.objects(Todo.self)
//            let clearQuickNote = localRealm.objects(QuickNote.self)
            
            
            //이거 초기화 되고 나서 실행할 얼럿self.customAlert(title: "Alert_SettingViewController_DataClear_UIAlertAction_Title".localized(), message: "Alert_SettingViewController_DataClear_UIAlertAction_Message".localized(), style: .alert, actions: ok)
            
        case 2:
            cell?.accessoryType = .none
            sendMail()
        case 3:
            let vc = AcknowListViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            cell?.accessoryType = .none
        }
    }
    
    func clearRealmData() {
        try! self.localRealm.write {
            self.localRealm.deleteAll()
        }
    }
    
    func switchToFirstView() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let sceneDelegate = windowScene?.delegate as? SceneDelegate
        let vc = PageViewController()
        let nav = UINavigationController(rootViewController: vc)
        
        sceneDelegate?.window?.rootViewController = nav
        sceneDelegate?.window?.makeKeyAndVisible()
    }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    
    func sendMail() {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setToRecipients(["newtrotodo@gmail.com"])
            mail.setSubject("SettingViewController_MailQuestions_Subject".localized())
            mail.mailComposeDelegate = self
            
            self.present(mail, animated: true)
        } else {
            //alert. 메일 등록을 해주시거나, 이메일로 문의 주세요
            let title = "SettingViewController_FailToMail_Alert_Title".localized()
            let message = "SettingViewController_FailToMail_Alert_Message".localized()
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let copy = UIAlertAction(title: "SettingViewController_CopyMailAddress_Alert_Title".localized(), style: .default) { action in
                UIPasteboard.general.string = "newtrotodo@gmail.com"
                self.view.makeToast("SettingViewController_CopyMailAddress_ToastMessage".localized())
            }
            let cancel = UIAlertAction(title: "SettingViewController_CopyMailAddress_CancelButton_Title".localized(), style: .cancel)
            alert.addAction(copy)
            alert.addAction(cancel)
            self.present(alert, animated: true)

        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled: //취소
            print("취소")
        case .saved: //임시저장
            print("임시저장")
        case .sent: //보냄
            print("보냄")
        case .failed: //전송실패
            print("실패")
        }
        controller.dismiss(animated: true)
    }
}

//extension SettingViewController: UIDocumentPickerDelegate {
//
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        print(#function)
//    }
//
//    //문서 선택 이후에 뭘 해줄겨
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//
//        guard let selectedFileURL = urls.first else {
//            view.makeToast("선택하신 파일을 찾을 수 없습니다.")
//            return
//        }
//
//        //도큐먼트 위치에 백업 파일 확인 = 도큐먼트 경로 갖고오기
//        guard let path = documentDirectoryPath() else {
//            self.view.makeToast("도큐먼트 위치에 오류가 있습니다.(백업실패)")
//            return
//        }
//
//        //압축파일의 경로를 지정해주는 코드
//        //~.zip
//        let sandboxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)
//
//        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
//            //압축파일 풀기
//            let fileURL = path.appendingPathComponent("New_Tro_TODO_1.zip")
//
//            do {
//                //풀어줄 파일 / 어디에 풀어줄건데 / 덮어쓸거냐 / 비밀번호 / 얼마나 진행된지(진행상황, 압축률 -> 로딩뷰 쓰기)
////                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
////                    print("압축 진행률  progress: \(progress)")
////                }, fileOutputHandler: { unzippedFile in
////                    print("unZippedFile: \(unzippedFile)")
////                    //zip파일이 누적이 되면 용량문제가 발생될 가능성이 있기때문에
////                    //사용자가 원하는 시점에 복구파일을 제거할 수 있도록 유도하는 기능도 필요하다
////                    //압축파일을 리스트로 만들어주고
////                    //스와이프 액션등으로 압축파일을 제거할 수 있게 만들어주는 기능도 필요할듯
////                })
////
//                try Zip.unzipFile(fileURL, destination: path , overwrite: true, password: nil, progress: { progress in
//                    }, fileOutputHandler: { [self] unzippedFile in
//                        print(unzippedFile)
//                        self.view.makeToast("복구가 완료되었습니다")
//
//                        localRealm.beginWrite()
//                            do {
//                                try self.localRealm.writeCopy(toFile: unzippedFile)
//                            } catch {
//                                // Error backing up data
//                            }
//                        localRealm.cancelWrite()
//
//                    }) //overwrite은 덮어씌우기
//            } catch {
//                view.makeToast("압축 해제에 실패했습니다")
//            }
//
//        } else {
//            //경로에 파일이 없기때문에 파일앱에서 경로 이동
//            do {
//                //파일 앱의 zip -> 도큐먼트 폴더에 복사
//                //선택한 URL -> LastComponent
//                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
//
//                let fileURL = path.appendingPathComponent("New_Tro_TODO_1.zip")
//
//                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
//                    print("압축 진행률  progress: \(progress)")
//                }, fileOutputHandler: { unzippedFile in
//                    print("unZippedFile: \(unzippedFile)")
//                })
//
//                let exitApp = UIAlertAction(title: "확인", style: .default) { action in
//                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        exit(0)
//                    }
//                }
//                self.customAlertOneButton(alertTitle: "앱 데이터 복구 완료", alertMessage: "앱이 강제종료됩니다", actionTitle: "확인", action: exitApp)
//
//            } catch {
//                self.view.makeToast("압축 해제에 실패했습니다.")
//            }
//
//        }
//
//    }
//}
