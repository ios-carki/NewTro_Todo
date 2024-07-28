//
//  AppDelegate.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import UIKit
import SwiftUI

import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseMessaging
import RealmSwift
import CustomTextField


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //MARK: About Widget Realm
        let defaultRealm = Realm.Configuration.defaultConfiguration.fileURL!
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.carki.NewTro_Todo")
        let realmURL = container?.appendingPathComponent("default.realm")
        var config: Realm.Configuration!

        // Checking the old realm config is exist
        if FileManager.default.fileExists(atPath: defaultRealm.path) {
            do {
                _ = try FileManager.default.replaceItemAt(realmURL!, withItemAt: defaultRealm)
               config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
            } catch {
               print("Error info: \(error)")
            }
        } else {
             config = Realm.Configuration(fileURL: realmURL, schemaVersion: 1)
        }

        Realm.Configuration.defaultConfiguration = config
        
        // Override point for customization after application launch.
        // iq키보드 spm -> 메이저 버전에 6.5.0
        sleep(2)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true //뷰 터치제스쳐, 키보드 자동으로 내림
        
        
        //로컬노티 딜리게이트
        UNUserNotificationCenter.current().delegate = self
        
        //파이어베이스 초기화 코드
        FirebaseApp.configure()
        
        //알림 시스템에 앱을 등록
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        //메시지 대리자 설정
        Messaging.messaging().delegate = self
        
        //현재 등록된 토큰 가져오기
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
          }
        }
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.mainBackGroundColor
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        //Custom TextField
        let shared = EGTextFieldConfig.shared
        shared.defaultTextColor = .white
        shared.defaultTitleColor = .white
        shared.titleFont = .galBold20()
        shared.defaultPlaceHolderTextColor = .placeHolderC
        shared.defaultBackgroundColor = .textFieldC
        shared.defaultBorderColor = .clear
        shared.defaultTrailingImageForegroundColor = .white
//        shared.defaultErrorTextColor = .statusAlert
//        shared.errorFont = .medium12()
        shared.cornerRadius = 12
        shared.textFieldHeight = 40
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

// MARK: - [노티피케이션 알림 딜리게이트 추가]
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //파베 메시징
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      Messaging.messaging().apnsToken = deviceToken
    }
    
    // [앱이 foreground 상태 일 때, 알림이 온 경우]
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("")
        print("===============================")
        print("[AppDelegate >> willPresent :: 앱 포그라운드 상태 푸시 알림 확인]")
        //print("[userInfo :: \(notification.request.content.userInfo)]")
        print("===============================")
        print("")
        
        // [completionHandler : 푸시 알림 상태창 표시]
        completionHandler([.banner, .list, .badge, .sound])
    }

    // [앱이 background 상태 일 때, 알림이 온 경우]
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        print("")
        print("===============================")
        print("[AppDelegate >> didReceive :: 앱 백그라운드 상태 푸시 알림 확인]")
        print("===============================")
        print("")
        
        //파베 유저 푸시클릭 확인
        print("사용자가 푸시를 클릭했습니다.")
        
        let userInfo = response.notification.request.content.userInfo
        
        if userInfo[AnyHashable("sesac")] as? String == "project" {
            print("SESAC PROJECT")
        } else {
            print("NOTHING")
        }

        // [completionHandler : 푸시 알림 상태창 표시]
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    
    //토큰 갱신 모니터링: 토큰 정보가 언제 바뀔까?
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊🦊: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

}
