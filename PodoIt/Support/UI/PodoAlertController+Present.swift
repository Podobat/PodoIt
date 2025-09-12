//
//  PodoAlertController+Present.swift
//  PodoIt
//
//  Created by 노가현 on 9/4/25.
//

import UIKit

extension PodoAlertController {
  // 범용 커스텀 알럿 표시
  static func present(
    from presenter: UIViewController,
    title: String,
    message: String,
    cancelTitle: String = "취소",
    confirmTitle: String = "확인",
    iconName: String? = nil,
    confirmColor: UIColor = .error,
    onConfirm: @escaping () -> Void = {}
  ) {
    guard presenter.presentedViewController == nil else { return }

    let vc = PodoAlertController(
      title: title,
      message: message,
      cancelTitle: cancelTitle,
      confirmTitle: confirmTitle,
      confirmColor: confirmColor,
      onConfirm: onConfirm
    )
    vc.modalPresentationStyle = .overFullScreen
    vc.modalTransitionStyle = .crossDissolve
    presenter.present(vc, animated: false)
    // 알럿 표시가 끝난 뒤, 컨테이너/타이틀을 찾아 아이콘 삽입
    if let iconName, !iconName.isEmpty {
      Self.attachIconIfPossible(
        to: vc,
        titleText: title,
        iconName: iconName,
        iconSide: 48,
        topInset: 16,
        spacingToTitle: 12
      )
    }
  }

  // 알림 권한 프리프롬프트 전용 헬퍼
  static func presentNotificationPreprompt(
    from presenter: UIViewController,
    onConfirm: @escaping () -> Void
  ) {
    present(
      from: presenter,
      title: "알림을 켜두면 더 편해요!",
      message: "소리나 배지로 알려드릴 수 있어요.\n원하면 설정에서 언제든 바꿀 수 있어요.",
      cancelTitle: "나중에",
      confirmTitle: "알림받기",
      iconName: "bell",
      confirmColor: Palette.Primary.p600,
      onConfirm: onConfirm
    )
  }

  // 오류/경고 알럿 (아이콘 없음 + error 버튼색)
  static func presentErrorAlert(
    from presenter: UIViewController,
    title: String,
    message: String,
    cancelTitle: String = "닫기",
    confirmTitle: String = "확인",
    onConfirm: @escaping () -> Void = {}
  ) {
    present(
      from: presenter,
      title: title,
      message: message,
      cancelTitle: cancelTitle,
      confirmTitle: confirmTitle,
      iconName: nil,
      confirmColor: .error,
      onConfirm: onConfirm
    )
  }
}

// MARK: - Private helpers (뷰 계층 탐색으로 아이콘 주입)

private extension PodoAlertController {
  // 컨테이너, 타이틀 UILabel을 찾아 이미지 뷰를 타이틀 위에 삽입
  static func attachIconIfPossible(
    to vc: PodoAlertController,
    titleText: String,
    iconName: String,
    iconSide: CGFloat,
    topInset: CGFloat,
    spacingToTitle: CGFloat
  ) {
    // 1) 이미지 로드
    guard let baseImage = UIImage(named: iconName)?
      .withRenderingMode(.alwaysOriginal) else { return }

    // 2) UIControl이 아니고 모서리 라운드가 있는 가장 앞쪽 뷰
    guard let container = findContainerView(in: vc.view) else { return }

    // 3) text가 titleText인 라벨
    guard let titleLabel = findTitleLabel(in: container, matching: titleText) else { return }

    // 4) 아이콘 뷰 생성 & 삽입
    let iconView = UIImageView(image: baseImage)
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.contentMode = .scaleAspectFit
    iconView.tintColor = nil // 템플릿일 때 틴트 방지

    container.addSubview(iconView)

    // 컨테이너 상단 여백 + 타이틀 위에 간격 유지 + 중앙 정렬
    NSLayoutConstraint.activate([
      iconView.topAnchor.constraint(equalTo: container.topAnchor, constant: topInset),
      iconView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
      iconView.widthAnchor.constraint(equalToConstant: iconSide),
      iconView.heightAnchor.constraint(equalToConstant: iconSide),

      // 아이콘과 타이틀 사이 간격
      titleLabel.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: spacingToTitle)
    ])

    // 레이아웃 갱신
    container.setNeedsLayout()
    container.layoutIfNeeded()
  }

  static func findContainerView(in root: UIView) -> UIView? {
    // UIControl이 아닌 UIView면서
    // cornerRadius가 있고 클립이 켜져있는 카드형 뷰
    for v in root.subviews.reversed() {
      if !(v is UIControl),
         v.layer.cornerRadius > 0,
         v.clipsToBounds == true
      {
        return v
      }
    }
    // 못 찾으면 서브뷰
    for v in root.subviews {
      if let found = findContainerView(in: v) {
        return found
      }
    }
    return nil
  }

  static func findTitleLabel(in container: UIView, matching title: String) -> UILabel? {
    // text == title || attributedText.string == title
    let allLabels = container.subviewsRecursive().compactMap { $0 as? UILabel }
    return allLabels.first {
      if let t = $0.text, t == title { return true }
      if let a = $0.attributedText, a.string == title { return true }
      return false
    }
  }
}

private extension UIView {
  func subviewsRecursive() -> [UIView] {
    subviews + subviews.flatMap { $0.subviewsRecursive() }
  }
}
