//
//  AppDelegate.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import UIKit
import SwiftUI

import FirebaseCore
import FirebaseCrashlytics
import RealmSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        RealmConfiguration.setup()

        // 전역 List/TextEditor 배경 투명 — 화면별 .scrollContentBackground(.hidden) 누락 시 안전망
        UITableView.appearance().backgroundColor = .clear
        UITextView.appearance().backgroundColor = .clear

        //로컬노티 딜리게이트
        UNUserNotificationCenter.current().delegate = self

        //파이어베이스 초기화 코드 — Crashlytics 도 이 시점에 signal handler 자동 등록.
        FirebaseApp.configure()

        // 개발 중 force unwrap / fatalError / SwiftUI preview 크래시까지 콘솔에 누적되면
        // 실제 사용자 크래시를 묻어버리므로 DEBUG 빌드에서는 수집을 끈다.
        // Release 빌드(아카이브 / TestFlight / App Store)에서는 활성.
#if DEBUG
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
#else
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
#endif

        // 로컬 알림 권한 요청 (원격 푸시/FCM 미사용 — 알림은 전부 로컬 스케줄)
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.mainBackGroundColor
        appearance.shadowColor = .clear

        let titleFont = UIFont(name: "Galmuri11-Bold", size: 17) ?? .boldSystemFont(ofSize: 17)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.inkC,
            .font: titleFont,
        ]

        // 백버튼 텍스트 숨김
        let backItemAppearance = UIBarButtonItemAppearance()
        backItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = backItemAppearance

        // 백버튼 chevron 색을 ink로 고정 (SwiftUI NavigationLink가 기본 시스템 틴트를 쓰는 문제 회피)
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let chevronImage = UIImage(systemName: "chevron.backward", withConfiguration: chevronConfig)?
            .withTintColor(.inkC, renderingMode: .alwaysOriginal)
        appearance.setBackIndicatorImage(chevronImage, transitionMaskImage: chevronImage)

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .inkC

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

// MARK: - 로컬 알림 딜리게이트
extension AppDelegate: UNUserNotificationCenterDelegate {

    // 앱이 foreground 상태일 때 로컬 알림이 도착한 경우 — 배너/사운드로 노출
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .badge, .sound])
    }

    // 사용자가 로컬 알림을 탭한 경우
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}
