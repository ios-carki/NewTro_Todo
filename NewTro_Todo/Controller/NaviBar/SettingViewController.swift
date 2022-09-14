//
//  SettingViewController.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/12.
//

import Foundation
import UIKit
import MessageUI

import Toast

final class SettingViewController: BaseViewController {
    
    let mainView = SettingView()
    let settingMenuList = ["버전정보", "테마", "데이터 백업 / 복구 / 초기화", "문의사항"]
    let settingImageList = ["info.circle", "paintbrush", "arrow.clockwise", "questionmark.circle"]
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naviSetting()
        tableSetting()
        view.backgroundColor = .mainBackGroundColor
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
            cell?.accessoryType = .none
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
            cell?.accessoryType = .none
        case 1:
            customAlertSimple(title: "준비중입니다", message: "새로운 테마가 업데이트 예정입니다.", cancelButtonText: "확인")
        case 2:
            let backUP = UIAlertAction(title: "백업", style: .default) { action in
                //백업 처리 구현해야됨
                print("백업 눌림")
            }
            let restore = UIAlertAction(title: "복구", style: .default) { action in
                //복구 처리 구현해야됨
                print("복구 눌림")
            }
            let clear = UIAlertAction(title: "초기화", style: .destructive) { action in
                //초기화 처리 구현해야되는데 초기화는 신중해야되니 별도의 alert 추가
                let ok = UIAlertAction(title: "데이터 삭제", style: .default) { action in
                    //초기화 처리 구현해야됨
                    print("데이터 초기화됨")
                }
                self.customAlert(title: "경고", message: "기기에 저장된 데이터가 삭제됩니다.", style: .alert, actions: ok)
            }
            customActionSheet(title: "백업 / 복구 / 초기화 선택", message: nil, actions: backUP, restore, clear)

        case 3:
            cell?.accessoryType = .none
            sendMail()
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
