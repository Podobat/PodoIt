//
//  UIViewController+Toast.swift
//  PodoIt
//
//  Created by 노가현 on 9/4/25.
//

import UIKit

extension UIViewController {
  func showToast(_ message: String,
                 icon: UIImage? = nil,
                 duration: TimeInterval = 1.5,
                 above anchorView: UIView)
  {
    // 컨테이너
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

    var constraints: [NSLayoutConstraint] = [
      container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      container.heightAnchor.constraint(equalToConstant: 48),
      container.bottomAnchor.constraint(equalTo: anchorView.topAnchor, constant: -20),
      label.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ]

    if let icon = icon {
      let iconView = UIImageView()
      iconView.image = icon.withRenderingMode(.alwaysOriginal)
      iconView.contentMode = .scaleAspectFit
      iconView.setContentHuggingPriority(.required, for: .horizontal)
      iconView.setContentCompressionResistancePriority(.required, for: .horizontal)

      container.addSubview(iconView)
      iconView.translatesAutoresizingMaskIntoConstraints = false

      constraints += [
        iconView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
        iconView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        iconView.widthAnchor.constraint(equalToConstant: 24),
        iconView.heightAnchor.constraint(equalToConstant: 24),

        label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 8),
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
      ]
    } else {
      constraints += [
        label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
        label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12)
      ]
    }

    NSLayoutConstraint.activate(constraints)

    // 애니메이션
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
