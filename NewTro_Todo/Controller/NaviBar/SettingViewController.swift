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
    let settingMenuList = ["테마", "데이터 초기화", "문의사항", "라이센스"]
    let settingImageList = ["paintbrush", "arrow.clockwise", "questionmark.circle", "info.circle"]
    
    let localRealm = try! Realm()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naviSetting()
        tableSetting()
        view.backgroundColor = .mainBackGroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .mainBackGroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.backgroundColor = .systemGray6
    }
    
    func naviSetting() {
        title = "설정"
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
    func documentDirectoryPath() -> URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        
        return documentDirectory
    }
    
    func backupFunction() {
        var urlPaths = [URL]()
        
        //도큐먼트 위치에 백업 파일 확인 = 도큐먼트 경로 갖고오기
        guard let path = documentDirectoryPath() else {
            self.view.makeToast("도큐먼트 위치에 오류가 있습니다.(백업실패)")
            return
        }
        
        //램 파일 갖고오기
        let realmFile = path.appendingPathComponent("default.realm") //램 파일이 없는경우 유효성검사 필요
        
        //램 파일 유효성 검사(있는지 없는지)
        guard FileManager.default.fileExists(atPath: realmFile.path) else {
            self.view.makeToast("백업할 파일이 없습니다.")
            return
        }
        
        urlPaths.append(URL(string: realmFile.path)!)
        
        //백업 파일을 압축: URL파일 만들기
        //압축 파일을 만들때 사용자가 압축한 시간을 명확하게 표현하기 위해서 압축파일명에 시간대를 추가해주는 작업도 필요할 듯
        //간단하게 Date()로 하면 되지만 UTC -> Locale화 시켜서 포맷을 해서 붙여주는게 낫다고 판단함
        do {
            let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "New_Tro_TODO_1")
            print("Archive Location: \(zipFilePath)")
            showActivityViewController()
            print("백업완료")
        } catch {
            self.view.makeToast("압축을 실패했습니다.")
        }
        
        //ActivityViewController
    }
    
    //ActivityViewController띄우는 메서드
    func showActivityViewController() {
        //도큐먼트 위치에 백업 파일 확인 = 도큐먼트 경로 갖고오기
        guard let path = documentDirectoryPath() else {
            self.view.makeToast("도큐먼트 위치에 오류가 있습니다.(백업실패)")
            return
        }
        
        //램 파일 갖고오기
        let backupFileURL = path.appendingPathComponent("New_Tro_TODO_1.zip") //램 파일이 없는경우 유효성검사 필요
        
        let vc = UIActivityViewController(activityItems: [backupFileURL], applicationActivities: [])
        self.present(vc, animated: true)
    }
    //MARK: -- 백업
    
    //MARK: -- 복구
    
    func restoreFunction() {
        
        let documnetPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.archive], asCopy: true)
        documnetPicker.delegate = self
        documnetPicker.allowsMultipleSelection = false //여러개 선택 못하게
        self.present(documnetPicker, animated: true)
        
    }
    //MARK: -- 복구
    
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
            customAlertSimple(title: "준비중입니다", message: "새로운 테마가 업데이트 예정입니다.", cancelButtonText: "확인")
        case 1:
            //초기화 처리 구현해야되는데 초기화는 신중해야되니 별도의 alert 추가
//            let clearTodo = localRealm.objects(Todo.self)
//            let clearQuickNote = localRealm.objects(QuickNote.self)
            
            let ok = UIAlertAction(title: "데이터 삭제", style: .default) { action in
                //초기화 처리 구현해야됨
                print("데이터 초기화됨")
                UserDefaults.standard.set(false, forKey: "oldUser")
                
                // 데이터 전체 삭제
                //        let del = realm.objects(Content.self)
                //        try? realm.write{
                //            realm.deleteAll(del)
                //        }
                //        alertA(msg: "데이터가 삭제 되었습니다.")
                
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
            self.customAlert(title: "경고", message: "기기에 저장된 데이터가 삭제됩니다.", style: .alert, actions: ok)
            
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
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    
    func sendMail() {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.setToRecipients(["94.nogari@gmail.com"])
            mail.setSubject("New-Tro Todo 문의사항 - ")
            mail.mailComposeDelegate = self
            
            self.present(mail, animated: true)
        } else {
            //alert. 메일 등록을 해주시거나, 이메일로 문의 주세요
            let title = "메일을 전송할 수 없습니다."
            let message = """
            (설정 앱 -> Mail -> 계정 -> 계정 연동 확인)
            or
            '94.nogari@gmail.com' 메일 전송
            """
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let copy = UIAlertAction(title: "문의 계정 복사", style: .default) { action in
                UIPasteboard.general.string = "94.nogari@gmail.com"
                self.view.makeToast("클립보드에 복사되었습니다.")
            }
            let cancel = UIAlertAction(title: "확인", style: .cancel)
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

extension SettingViewController: UIDocumentPickerDelegate {
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print(#function)
    }
    
    //문서 선택 이후에 뭘 해줄겨
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedFileURL = urls.first else {
            view.makeToast("선택하신 파일을 찾을 수 없습니다.")
            return
        }
        
        //도큐먼트 위치에 백업 파일 확인 = 도큐먼트 경로 갖고오기
        guard let path = documentDirectoryPath() else {
            self.view.makeToast("도큐먼트 위치에 오류가 있습니다.(백업실패)")
            return
        }
        
        //압축파일의 경로를 지정해주는 코드
        //~.zip
        let sandboxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            //압축파일 풀기
            let fileURL = path.appendingPathComponent("New_Tro_TODO_1.zip")
            
            do {
                //MARK: -- 여기서부터 우석이한테 피드백
                //풀어줄 파일 / 어디에 풀어줄건데 / 덮어쓸거냐 / 비밀번호 / 얼마나 진행된지(진행상황, 압축률 -> 로딩뷰 쓰기)
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("압축 진행률  progress: \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("unZippedFile: \(unzippedFile)")
                    //zip파일이 누적이 되면 용량문제가 발생될 가능성이 있기때문에
                    //사용자가 원하는 시점에 복구파일을 제거할 수 있도록 유도하는 기능도 필요하다
                    //압축파일을 리스트로 만들어주고
                    //스와이프 액션등으로 압축파일을 제거할 수 있게 만들어주는 기능도 필요할듯
                })
//
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
            } catch {
                view.makeToast("압축 해제에 실패했습니다")
            }
            
        } else {
            //경로에 파일이 없기때문에 파일앱에서 경로 이동
            do {
                //파일 앱의 zip -> 도큐먼트 폴더에 복사
                //선택한 URL -> LastComponent
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                
                let fileURL = path.appendingPathComponent("New_Tro_TODO_1.zip")
                
                try Zip.unzipFile(fileURL, destination: path, overwrite: true, password: nil, progress: { progress in
                    print("압축 진행률  progress: \(progress)")
                }, fileOutputHandler: { unzippedFile in
                    print("unZippedFile: \(unzippedFile)")
                })
                
//                let exitApp = UIAlertAction(title: "확인", style: .default) { action in
//                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                        exit(0)
//                    }
//                }
//                self.customAlertOneButton(alertTitle: "앱 데이터 복구 완료", alertMessage: "앱이 강제종료됩니다", actionTitle: "확인", action: exitApp)
                
            } catch {
                self.view.makeToast("압축 해제에 실패했습니다.")
            }
            
        }
        
    }
}
