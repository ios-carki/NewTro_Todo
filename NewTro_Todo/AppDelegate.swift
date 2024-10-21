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

        // Define the new configuration with migration
        config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used version.
            // Specify the file URL for the Realm database
            fileURL: realmURL,
            schemaVersion: 2,
            // Define the migration block
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // Perform migration for DiaryModel
                    migration.enumerateObjects(ofType: Todo.className()) { oldObject, newObject in
                        // 문자열을 Date로 변환
                        if let stringDate = oldObject?["stringDate"] as? String {
                            // DateFormatter로 String을 Date로 변환
                            let formatter = DateFormatter()
                            formatter.locale = Locale.current // POSIX 로케일 설정
                            formatter.timeZone = TimeZone(abbreviation: "UTC")   // UTC 타임존 설정
                            
                            // 시도할 여러 가지 포맷
                            let possibleFormats = [
                                "MMM dd yyyy",         // "Oct 16 2024" 형식
                                "yyyy년 MM월 dd일"     // "2024년 10월 16일" 형식
                            ]
                            // 가능한 포맷을 순회하며 날짜 변환 시도
                            for format in possibleFormats {
                                formatter.dateFormat = format
                                if let date = formatter.date(from: stringDate) {
                                    // UTC 기준으로 시, 분, 초를 0으로 변환하여 자정 시간으로 설정
                                    let calendar = Calendar.current
                                    var components = calendar.dateComponents([.year, .month, .day], from: date)
                                    components.timeZone = TimeZone(abbreviation: "UTC")
                                    
                                    // 자정으로 설정된 Date
                                    if let dateOnly = calendar.date(from: components) {
                                        newObject?["selectedDate"] = dateOnly
                                    }
                                }
                            }
                        }
                    }
                }
            }
            // Optionally, set other configuration options here
            // e.g., encryptionKey, readOnly, etc.
        )

        // Set the new configuration as the default configuration
        Realm.Configuration.defaultConfiguration = config

        do {
            // Initialize Realm with the new configuration, triggering migration if needed
            let realm = try Realm()
            print("Realm initialized successfully with schema version \(config.schemaVersion)")
        } catch {
            // Handle initialization errors
            print("Failed to initialize Realm: \(error.localizedDescription)")
        }
        
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
        
//        //Custom TextField
//        let shared = EGTextFieldConfig.shared
//        shared.defaultTextColor = .white
//        shared.defaultTitleColor = .white
//        shared.titleFont = .galBold20()
//        shared.defaultPlaceHolderTextColor = .placeHolderC
//        shared.defaultBackgroundColor = .textFieldC
//        shared.defaultBorderColor = .clear
//        shared.defaultTrailingImageForegroundColor = .white
////        shared.defaultErrorTextColor = .statusAlert
////        shared.errorFont = .medium12()
//        shared.cornerRadius = 12
//        shared.textFieldHeight = 40
        
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
