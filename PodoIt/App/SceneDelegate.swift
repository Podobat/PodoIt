//
//  SceneDelegate.swift
//  PodoIt
//
//  Created by 노가현 on 8/16/25.
//

import SwiftData
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  private var modelContainer: ModelContainer!
  private var modelContext: ModelContext!
  private var timerRepository: TimerRepository!

  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions)
  {
    guard let windowScene = scene as? UIWindowScene else { return }

    do {
      modelContainer = try ModelContainer(for: TimerModel.self)
      modelContext = ModelContext(modelContainer)
      timerRepository = SwiftDataTimerRepository(context: modelContext)
    } catch {
      assertionFailure("SwiftData ModelContainer 생성 실패: \(error)")
      return
    }

    let window = UIWindow(windowScene: windowScene)

    let rootVC = MainTabBarController(repository: timerRepository)
    window.rootViewController = rootVC
    window.makeKeyAndVisible()

    self.window = window
  }

  func sceneDidDisconnect(_ scene: UIScene) {}
  func sceneDidBecomeActive(_ scene: UIScene) {}
  func sceneWillResignActive(_ scene: UIScene) {}
  func sceneWillEnterForeground(_ scene: UIScene) {}
  func sceneDidEnterBackground(_ scene: UIScene) {}
}
