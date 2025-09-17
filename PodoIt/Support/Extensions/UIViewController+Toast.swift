//
//  UIViewController+Toast.swift
//  PodoIt
//
//  Created by 노가현 on 9/4/25.
//

import UIKit

extension UIViewController {
  func showToastAbove(_ message: String,
                 icon: UIImage? = nil,
                 duration: TimeInterval = 1.5,
                 above anchorView: UIView)
  {
    let container = makeToastContainer(message: message, icon: icon)
    setupToastBaseContainer(container)
    positionToastAbove(container: container, above: anchorView, spacing: -20)
    animateToast(container, duration: duration, message: message)
  }
  
  func showToastBelow(
    _ message: String,
    icon: UIImage? = nil,
    duration: TimeInterval = 1.5,
    above anchorView: UIView
  ) {
    let container = makeToastContainer(message: message, icon: icon)
    setupToastBaseContainer(container)
    positionToastBelow(container: container, below: anchorView, spacing: 8)
    animateToast(container, duration: duration, message: message)
  }

  // MARK: - 컨테이너

  private func makeToastContainer(message: String, icon: UIImage?) -> UIView {
    let container = UIView()
    container.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    container.layer.cornerRadius = 8
    container.clipsToBounds = true
    container.alpha = 0
    container.isAccessibilityElement = true
    container.accessibilityLabel = message

    // 라벨
    let label = UILabel()
    label.text = message
    label.textColor = .white
    label.font = Typography.font(for: .bodyLg(weight: .semibold))
    label.textAlignment = .left
    label.numberOfLines = 1

    view.addSubview(container)
    container.addSubview(label)
    container.translatesAutoresizingMaskIntoConstraints = false
    label.translatesAutoresizingMaskIntoConstraints = false

    // 아이콘
    if let icon = icon {
      let iconView = UIImageView()
      iconView.image = icon.withRenderingMode(.alwaysOriginal)
      iconView.contentMode = .scaleAspectFit
      iconView.setContentHuggingPriority(.required, for: .horizontal)
      iconView.setContentCompressionResistancePriority(.required, for: .horizontal)

      container.addSubview(iconView)
      iconView.translatesAutoresizingMaskIntoConstraints = false

      UIKit.NSLayoutConstraint.activate([
        iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
        iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        iconView.widthAnchor.constraint(equalToConstant: 24),
        iconView.heightAnchor.constraint(equalToConstant: 24),

        label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
        label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
      ])
    } else {
      UIKit.NSLayoutConstraint.activate([
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
        label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
      ])
    }
    return container
  }

  // 공통 외곽 (좌우/높이)
  private func setupToastBaseContainer(_ container: UIView) {
    UIKit.NSLayoutConstraint.activate([
      container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      container.heightAnchor.constraint(equalToConstant: 48)
    ])
  }

  // anchorView를 기준으로 위에 붙이는 메서드
  private func positionToastAbove(container: UIView, above anchorView: UIView, spacing: CGFloat) {
    UIKit.NSLayoutConstraint.activate([
      container.bottomAnchor.constraint(equalTo: anchorView.topAnchor, constant: spacing)
    ])
  }
  
  // anchorView를 기준으로 아래에 붙이는 메서드
  private func positionToastBelow(container: UIView, below anchorView: UIView, spacing: CGFloat) {
    UIKit.NSLayoutConstraint.activate([
      container.topAnchor.constraint(equalTo: anchorView.topAnchor, constant: spacing)
    ])
  }

  // 애니메이션
  private func animateToast(_ container: UIView, duration: TimeInterval, message: String) {
    UIView.animate(withDuration: 0.2, animations: {
      container.alpha = 1
    }) { _ in
      UIAccessibility.post(notification: .announcement, argument: message)
      UIView.animate(withDuration: 0.25, delay: duration, options: [.curveEaseInOut], animations: {
        container.alpha = 0
      }, completion: { _ in
        container.removeFromSuperview()
      })
    }
  }
}
