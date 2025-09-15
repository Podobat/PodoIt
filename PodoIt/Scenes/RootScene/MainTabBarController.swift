//
//  MainTabBarController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SwiftData
import UIKit

final class MainTabBarController: UITabBarController {
  // Repository 보관
  private let repository: TimerRepository
  private var initialTimerID: UUID?

  // 지정 이니셜라이저 추가
  init(repository: TimerRepository, initialTimerID: UUID? = nil) {
    self.repository = repository
    self.initialTimerID = initialTimerID
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupAppearance() // 탭바 (컬러/폰트) 설정
    setupViewControllers() // 탭별 화면 연결
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    guard let id = initialTimerID else { return }
    // 타이머 탭 선택
    selectedIndex = 0 // psuh전 탭을 TimerVC로 강제. 이래야 TimerRunVC에서 pop해도 TimerVC로 pop 실행됨
    if let nav = viewControllers?.first as? UINavigationController {
      guard let timer = try? repository.fetch(by: id) else {
        self.initialTimerID = nil
        return
      }
      let timerRunVC = TimerRunViewController(timer: timer, repo: repository)
      timerRunVC.hidesBottomBarWhenPushed = true
      nav.pushViewController(timerRunVC, animated: false)
      self.initialTimerID = nil // 매번 저 화면으로 push할게 아니기에 1번만 하고 nil
    }
  }

  private func setupAppearance() {
    let selected = Palette.Primary.p600 // 선택된 아이템 색상
    let unselected = Palette.Gray.g400 // 미선택 아이템 색상
    let bg = Palette.App.white // 탭바 배경색

    if #available(iOS 15.0, *) {
      let appearance = UITabBarAppearance()
      appearance.configureWithOpaqueBackground()
      appearance.backgroundColor = bg

      // 선택/미선택 상태
      func style(_ item: UITabBarItemAppearance) {
        item.normal.iconColor = unselected
        item.normal.titleTextAttributes = [.foregroundColor: unselected]
        item.selected.iconColor = selected
        item.selected.titleTextAttributes = [.foregroundColor: selected]
      }

      // 모든 레이아웃 모드에 동일하게
      [appearance.stackedLayoutAppearance,
       appearance.inlineLayoutAppearance,
       appearance.compactInlineLayoutAppearance].forEach(style)

      tabBar.standardAppearance = appearance
      tabBar.scrollEdgeAppearance = appearance
    } else {
      tabBar.barTintColor = bg
      tabBar.tintColor = selected
      tabBar.unselectedItemTintColor = unselected
    }
  }

  // 컨테이너 생성 삭제, 주입받은 repository 사용
  private func setupViewControllers() {
    viewControllers = [
      makeNav(TimerViewController(repository: repository), "타이머", "timer"),
      makeNav(StatsViewController(), "통계", "stats"),
      makeNav(SettingViewController(), "설정", "setting")
    ]
  }

  // 탭바 아이템 설정
  private func makeNav(_ root: UIViewController, _ title: String, _ icon: String) -> UINavigationController {
    let nav = UINavigationController(rootViewController: root)
    nav.tabBarItem = UITabBarItem(
      title: title,
      image: UIImage(named: icon)?.withRenderingMode(.alwaysTemplate),
      selectedImage: UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
    )
    return nav
  }
}
