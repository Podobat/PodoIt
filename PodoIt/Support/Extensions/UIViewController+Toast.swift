//
//  UIViewController+Toast.swift
//  PodoIt
//
//  Created by 노가현 on 9/4/25.
//

import UIKit

extension UIViewController {
  func showToast(_ message: String,
                 duration: TimeInterval = 1.5,
                 above anchorView: UIView)
  {
    let toast = UILabel()
    toast.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    toast.textColor = .white
    toast.font = Typography.font(for: .bodyLg(weight: .semibold))
    toast.textAlignment = .center
    toast.text = message
    toast.numberOfLines = 1
    toast.alpha = 0
    toast.layer.cornerRadius = 8
    toast.clipsToBounds = true
    toast.isAccessibilityElement = true
    toast.accessibilityLabel = message

    view.addSubview(toast)
    toast.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      toast.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      toast.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      toast.heightAnchor.constraint(equalToConstant: 48),
      toast.bottomAnchor.constraint(equalTo: anchorView.topAnchor, constant: -20)
    ])

    UIView.animate(withDuration: 0.2, animations: {
      toast.alpha = 1
    }) { _ in
      UIAccessibility.post(notification: .announcement, argument: message)
      UIView.animate(withDuration: 0.25, delay: duration, options: [.curveEaseInOut], animations: {
        toast.alpha = 0
      }, completion: { _ in
        toast.removeFromSuperview()
      })
    }
  }
}
