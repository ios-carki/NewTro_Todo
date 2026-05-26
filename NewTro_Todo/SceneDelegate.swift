//
//  SceneDelegate.swift
//  NewTro_Todo
//
//  Created by Carki on 2022/09/06.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let coordinator = AppCoordinator(window: window, diContainer: DIContainer())
        appCoordinator = coordinator
        coordinator.start()
    }

    func restartApp() {
        guard let window else { return }
        let coordinator = AppCoordinator(window: window, diContainer: DIContainer())
        appCoordinator = coordinator
        coordinator.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    //노티 뱃지 초기화 포함
    func sceneDidBecomeActive(_ scene: UIScene) {
        // [앱 접속 시 : 푸시 알림 뱃지 카운트 초기화 실시]
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 누락된 루틴 Todo 를 따라잡는다 (오늘+horizonDays 까지 idempotent 생성).
        Task { @MainActor in
            appCoordinator?.materializeRoutines()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

