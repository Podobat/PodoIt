//
//  TimerViewController.swift
//  PodoIt
//
//  Created by 노가현 on 8/20/25.
//

import SnapKit
import SwiftData
import Then
import UIKit
import UserNotifications

final class TimerViewController: UIViewController, UICollectionViewDelegateFlowLayout { // 사이즈 계산을 위해서 채택

  // MARK: - Dependencies

  private let repository: TimerRepository

  // MARK: - State

  private var timers: [TimerModel] = []
  private let maxTimers: Int = 5

  // 알림 커스텀 알럿
  private let notifPrepromptKey = "notif.preprompt.shown"
  private var hasShownNotifPreprompt: Bool {
    get { UserDefaults.standard.bool(forKey: notifPrepromptKey) }
    set { UserDefaults.standard.set(newValue, forKey: notifPrepromptKey) }
  }

  // init 추가
  init(repository: TimerRepository) {
    self.repository = repository
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Constants

  private enum Layout {
    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 16
    static let dividerHeight: CGFloat = 1
    static let emptyTopOffset: CGFloat = 240
    static let addButtonBottomOffset: CGFloat = -16
    static let addButtonHeight: CGFloat = 48
    static let minimumLineSpacing: CGFloat = 12
    static let sectionInset = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    static let cellHeight: CGFloat = 96
  }

  // MARK: - UI Components

  private let headerView = TimerHeaderView()
  private let emptyStateView = EmptyStateView()

  private let backgroundContainerView = UIView().then {
    $0.backgroundColor = .gray100
  }

  private let addButton = UIButton(type: .system).then {
    let image = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.titleLabel?.font = Typography.font(for: .labelLg)
    $0.layer.cornerRadius = 24
    $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    $0.semanticContentAttribute = .forceLeftToRight
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
  }

  private lazy var collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = Layout.minimumLineSpacing
    layout.sectionInset = Layout.sectionInset
    layout.estimatedItemSize = .zero // 고정 사이즈

    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .clear
    cv.register(TimerCell.self, forCellWithReuseIdentifier: TimerCell.reuseIdentifier)
    cv.dataSource = self
    cv.delegate = self
    return cv
  }()

  // MARK: - Helpers

  private var isAtLimit: Bool { timers.count >= maxTimers }

  private func updateUI() {
    if timers.isEmpty {
      emptyStateView.isHidden = false
      collectionView.isHidden = true
    } else {
      emptyStateView.isHidden = true
      collectionView.isHidden = false
    }

    updateAddButtonState()
  }

  private func updateAddButtonState() {
    // 터치가 뒤로 통과하지 않도록 버튼은 항상 터치 가능 상태 유지
    addButton.isEnabled = true
    addButton.isUserInteractionEnabled = true

    // 5개면 비활성화 + gray200, 아니면 활성 + 기본 색
    if isAtLimit {
      addButton.backgroundColor = Palette.Gray.g200
      addButton.setTitle("최대 갯수 도달", for: .normal)
      addButton.setTitleColor(Palette.Gray.g400, for: .normal)
      addButton.tintColor = Palette.Gray.g400
    } else {
      addButton.backgroundColor = Palette.Primary.p600
      addButton.setTitle("추가하기", for: .normal)
      addButton.setTitleColor(.appWhite, for: .normal)
      addButton.tintColor = .appWhite
    }
  }

  private func reloadData() {
    do {
      timers = try repository.fetchAll()
      collectionView.reloadData()
      updateUI()
      // 헤더 총 집중 시간 업데이트
      updateHeaderTotalFocusTime()
    } catch {
      print("❌ fetch 실패: \(error)")
      // 사용자에게 에러 알림 표시
      timers = []
      collectionView.reloadData()
      updateUI()
      updateHeaderTotalFocusTime()
    }
  }

  // MARK: - Lifecycle

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadData()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.setNavigationBarHidden(true, animated: false)
    navigationItem.largeTitleDisplayMode = .never
    configureUI()
    addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    setupNotificationObservers()
    // 초기 상태 반영
    updateAddButtonState()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // 커스텀 알럿 1번만 표시
    maybeShowNotifPrepromptIfNeeded()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // 항상 버튼이 위에 오도록
    view.bringSubviewToFront(addButton)
  }

  // MARK: - Actions

  @objc private func addButtonTapped() {
    // 5개면 더 못 만들게 막기
    guard !isAtLimit else { return }

    // ViewModel 주입
    let vm = TimerEditViewModel()
    let editVC = TimerEditViewController(viewModel: vm)
    editVC.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(editVC, animated: true)
  }

  // MARK: - Notification Preprompt

  private func maybeShowNotifPrepromptIfNeeded() {
    // 이미 보여줬으면 스킵
    guard hasShownNotifPreprompt == false else { return }

    // 권한이 결정된 상태면 스킵
    UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
      guard let self else { return }
      guard settings.authorizationStatus == .notDetermined else { return }

      // 프레임 그려진 뒤 지연
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
        guard let self else { return }
        // 다른 모달이 떠 있으면 보류
        let presenter = self.navigationController ?? self
        guard presenter.presentedViewController == nil else { return }
        self.showNotifPreprompt()
        // 취소해도 다시 안 뜨게
        self.hasShownNotifPreprompt = true
      }
    }
  }

  private func showNotifPreprompt() {
    let presenter = navigationController ?? self
    PodoAlertController.presentNotificationPreprompt(from: presenter) { [weak self] in
      // 커스텀 알럿이 닫힌 뒤 잠깐 기다렸다가 시스템 프롬프트 띄우기
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
        self?.requestSystemNotificationAuthorization()
      }
    }
  }

  // 시스템 알림 권한 프롬프트
  private func requestSystemNotificationAuthorization() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if let error { print("권한 요청 오류:", error) }

      DispatchQueue.main.async {
        if granted {
          print("알림 권한 허용")
        } else {
          print("알림 권한 거부")
        }
      }
    }
  }

  // MARK: - UI Setup

  private func configureUI() {
    view.backgroundColor = .appWhite
    setupViews()
    setupConstraints()
  }

  private func setupViews() {
    for item in [headerView, backgroundContainerView, collectionView, emptyStateView, addButton] {
      view.addSubview(item)
    }
  }

  private func setupConstraints() {
    headerView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
      $0.leading.trailing.equalToSuperview()
    }

    backgroundContainerView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom).offset(20)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide)
    }

    collectionView.snp.makeConstraints {
      $0.top.equalTo(backgroundContainerView.snp.top)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(backgroundContainerView.snp.bottom)
    }

    emptyStateView.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.centerY.equalTo(backgroundContainerView.snp.centerY)
      $0.leading.trailing.equalToSuperview().inset(Layout.sectionInset.left)
    }

    addButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(Layout.addButtonBottomOffset)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(Layout.addButtonHeight)
    }
    collectionView.contentInset.bottom = Layout.addButtonHeight + 16
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize
  {
    guard let flow = collectionViewLayout as? UICollectionViewFlowLayout else {
      return CGSize(width: collectionView.bounds.width, height: Layout.cellHeight)
    }
    let width = collectionView.bounds.width - flow.sectionInset.left - flow.sectionInset.right
    return CGSize(width: width, height: Layout.cellHeight)
  }

  // 셀 탭 시 수정 화면 진입 같은 기본 동작
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // TimerEditViewController에 수정 모드 생성자가 구현되면 수정
    let editing = timers[indexPath.item]
    let vm = TimerEditViewModel(editing: editing)
    let editVC = TimerEditViewController(viewModel: vm)
    editVC.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(editVC, animated: true)
  }

  // MARK: - Helper Methods

  // 특정 타이머의 오늘 집중 시간을 조회 -> 포맷팅된 문자열로 반환
  private func getTodayFocusTime(for timerTitle: String) -> String {
    do {
      let today = Date()
      let totalSeconds = try getTodayFocusSeconds(for: timerTitle, on: today)
      return formatTime(seconds: totalSeconds)
    } catch {
      print("오늘 집중 시간 조회 실패: \(error)")
      return "00:00:00"
    }
  }

  // 특정 타이머의 오늘 집중 시간을 초 단위로 조회
  private func getTodayFocusSeconds(for timerTitle: String, on date: Date) throws -> Int {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

    // 오늘 날짜의 해당 타이머 통계 데이터 조회
    let stats = try SwiftDataManager.shared.fetchStats(
      from: startOfDay,
      to: endOfDay,
      categoryName: timerTitle
    )

    // 모든 통계 데이터의 시간을 초로 변환하여 합산
    var totalSeconds = 0
    for stat in stats {
      totalSeconds += parseTimeToSeconds(stat.time)
    }

    return totalSeconds
  }

  // HH:MM:SS 형식의 시간 문자열 -> 초로 변환
  private func parseTimeToSeconds(_ timeString: String) -> Int {
    let components = timeString.split(separator: ":").compactMap { Int($0) }
    guard components.count == 3 else { return 0 }

    let hours = components[0]
    let minutes = components[1]
    let seconds = components[2]

    return hours * 3600 + minutes * 60 + seconds
  }

  // HH:MM:SS 형식으로 포맷팅
  private func formatTime(seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let secs = seconds % 60
    return String(format: "%02d:%02d:%02d", hours, minutes, secs)
  }

  // 오늘 전체 카테고리의 총 집중 시간을 계산하고 헤더에 반영
  private func updateHeaderTotalFocusTime(date: Date = Date()) {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)
    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
    do {
      // 전체로 조회해서 오늘의 모든 기록 가져오기
      let allStats = try SwiftDataManager.shared.fetchStats(from: startOfDay, to: endOfDay, categoryName: "전체")
      let totalSeconds = allStats.reduce(0) { acc, stat in acc + parseTimeToSeconds(stat.time) }
      let formatted = formatTime(seconds: totalSeconds)
      headerView.updateTotalTime(formatted)
    } catch {
      // 실패 시 00:00:00 표시 유지
      headerView.updateTotalTime("00:00:00")
    }
  }

  // 통계 데이터 변경 알림을 구독하여 UI 업데이트
  private func setupNotificationObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleStatsDidChange),
      name: .statsDidChange,
      object: nil
    )
  }

  @objc private func handleStatsDidChange() {
    // 통계 데이터가 변경되면 컬렉션 뷰를 새로고침해서 집중 시간 업데이트
    DispatchQueue.main.async { [weak self] in
      self?.collectionView.reloadData()
      self?.updateHeaderTotalFocusTime()
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - UICollectionViewDataSource

extension TimerViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return min(timers.count, maxTimers)
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: TimerCell.reuseIdentifier,
      for: indexPath
    ) as? TimerCell else {
      return UICollectionViewCell()
    }

    let model = timers[indexPath.item]

    // 오늘 집중 시간 조회
    let todayFocusTime = getTodayFocusTime(for: model.title)
    cell.configure(with: model, today: todayFocusTime)

    // 셀 → VC로 버튼 탭 이벤트 전달
    cell.onPlayTapped = { [weak self] in
      guard let self = self else { return }
      let timer = self.timers[indexPath.item]
      // 타이머 실행 화면으로 이동
      let runVC = TimerRunViewController(timer: timer) // timer 전달
      runVC.hidesBottomBarWhenPushed = true // 탭바 숨기기
      self.navigationController?.pushViewController(runVC, animated: true)
    }

    return cell
  }
}
