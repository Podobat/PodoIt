//
//  PodoAlertController.swift
//  PodoIt
//
//  Created by 노가현 on 8/28/25.
//

import SnapKit
import Then
import UIKit

final class PodoAlertController: UIViewController {
  private enum Metrics {
    static let containerCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 12
    static let horizontalInset: CGFloat = 32
    static let contentInset: CGFloat = 16
    static let interTitleMessage: CGFloat = 8
    static let interMessageButtons: CGFloat = 16
    static let buttonSpacing: CGFloat = 8
    static let buttonHeight: CGFloat = 48
  }

  // MARK: - API

  static func presentDeleteTimerAlert(
    from presenter: UIViewController,
    title: String = "이 타이머를 삭제할까요?",
    message: String = "삭제한 타이머는 복구할 수 없어요.",
    cancelTitle: String = "취소",
    confirmTitle: String = "삭제하기",
    onConfirm: @escaping () -> Void
  ) {
    let vc = PodoAlertController(
      title: title,
      message: message,
      cancelTitle: cancelTitle,
      confirmTitle: confirmTitle,
      confirmColor: .error,
      onConfirm: onConfirm
    )
    vc.modalPresentationStyle = .overFullScreen // 반투명
    vc.modalTransitionStyle = .crossDissolve // fase in/out
    presenter.present(vc, animated: false) // 알럿 표시
  }

  static func presentStopTimerAlert(
    from presenter: UIViewController,
    title: String = """
    아직 목표 시간을 채우지 않았어요.
    그래도 종료할까요?
    """,
    message: String = "1분 이상 집중한 시간은 그대로 기록돼요.",
    cancelTitle: String = "계속하기",
    confirmTitle: String = "그만두기",
    onConfirm: @escaping () -> Void
  ) {
    let vc = PodoAlertController(
      title: title,
      message: message,
      cancelTitle: cancelTitle,
      confirmTitle: confirmTitle,
      confirmColor: .primary600,
      onConfirm: onConfirm
    )
    vc.modalPresentationStyle = .overFullScreen
    vc.modalTransitionStyle = .crossDissolve
    presenter.present(vc, animated: true)
  }

  // MARK: - Init

  private let confirmHandler: () -> Void

  init(title: String,
       message: String,
       cancelTitle: String,
       confirmTitle: String,
       confirmColor: UIColor,
       onConfirm: @escaping () -> Void)
  {
    self.confirmHandler = onConfirm
    super.init(nibName: nil, bundle: nil)

    titleLabel.attributedText = centered(Typography.attributed(title, style: .headingLg, color: .appBlack))
    messageLabel.attributedText = centered(messageLabelTargetBolding(fullText: message, boldTarget: "1분 이상"))

    cancelButton.setAttributedTitle(
      Typography.attributed(cancelTitle, style: .labelLg(weight: .semibold), color: .gray900),
      for: .normal
    )
    confirmButton.setAttributedTitle(
      Typography.attributed(confirmTitle, style: .labelLg(weight: .semibold), color: .appWhite),
      for: .normal
    )
    confirmButton.backgroundColor = confirmColor
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  // MARK: - Views

  private let dimView = UIControl().then {
    $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    $0.alpha = 0
  }

  private let containerView = UIView().then {
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = Metrics.containerCornerRadius
    $0.layer.cornerCurve = .continuous
    $0.clipsToBounds = true
  }

  private let titleLabel = UILabel().then {
    $0.numberOfLines = 0
  }

  private let messageLabel = UILabel().then {
    $0.numberOfLines = 0
  }

  private let cancelButton = UIButton(type: .system).then {
    $0.backgroundColor = .gray100
    $0.layer.cornerRadius = Metrics.buttonCornerRadius
    $0.accessibilityIdentifier = "podoAlert.cancel"
  }

  private let confirmButton = UIButton(type: .system).then {
    $0.layer.cornerRadius = Metrics.buttonCornerRadius
    // $0.contentEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    $0.accessibilityIdentifier = "podoAlert.confirm"
  }

  private let buttonStack = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = Metrics.buttonSpacing
    $0.distribution = .fillEqually
  }

  private let contentStack = UIStackView().then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = Metrics.interTitleMessage
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(
      top: Metrics.contentInset, left: Metrics.contentInset,
      bottom: Metrics.contentInset, right: Metrics.contentInset
    )
  }

  // MARK: - Lifecycle

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .clear
    layout()
    bind()
    animateIn()
  }

  private func layout() {
    view.addSubview(dimView)
    view.addSubview(containerView)
    dimView.snp.makeConstraints { $0.edges.equalToSuperview() }

    contentStack.addArrangedSubview(titleLabel)
    contentStack.setCustomSpacing(8, after: titleLabel)

    contentStack.addArrangedSubview(messageLabel)
    contentStack.setCustomSpacing(16, after: messageLabel)

    buttonStack.addArrangedSubviews([cancelButton, confirmButton])
    contentStack.addArrangedSubview(buttonStack)
    containerView.addSubview(contentStack)

    // 중앙 배치 전용
    containerView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(Metrics.horizontalInset)
    }

    contentStack.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    buttonStack.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(Metrics.contentInset)
    }

    for btn in [cancelButton, confirmButton] {
      btn.snp.makeConstraints { $0.height.equalTo(Metrics.buttonHeight) }
    }
  }

  private func bind() {
    dimView.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
    cancelButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
    confirmButton.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
  }

  // MARK: - Animations

  private func animateIn() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    containerView.transform = CGAffineTransform(translationX: 0, y: 20)
    containerView.alpha = 0

    UIView.animate(withDuration: 0.2) { self.dimView.alpha = 1 }
    UIView.animate(withDuration: 0.28,
                   delay: 0,
                   usingSpringWithDamping: 0.9,
                   initialSpringVelocity: 0.6,
                   options: .curveEaseInOut)
    {
      self.containerView.alpha = 1
      self.containerView.transform = .identity
    }
  }

  private func animateOut(completion: @escaping () -> Void) {
    UIView.animate(withDuration: 0.18, animations: {
      self.dimView.alpha = 0
      self.containerView.alpha = 0
      self.containerView.transform = CGAffineTransform(translationX: 0, y: 10)
    }, completion: { _ in completion() })
  }

  // MARK: - Actions

  @objc private func handleDismiss() {
    animateOut { [weak self] in self?.dismiss(animated: false) }
  }

  @objc private func handleConfirm() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    let handler = confirmHandler
    animateOut { [weak self] in
      self?.dismiss(animated: false) { handler() }
    }
  }
}

extension PodoAlertController {
  private func centered(_ attr: NSAttributedString) -> NSAttributedString {
    let m = NSMutableAttributedString(attributedString: attr)
    let p = NSMutableParagraphStyle()
    p.alignment = .center
    p.lineBreakMode = .byWordWrapping
    m.addAttribute(
      .paragraphStyle,
      value: p,
      range: NSRange(location: 0, length: m.length)
    )
    return m
  }

  private func messageLabelTargetBolding(fullText: String, boldTarget: String) -> NSAttributedString {
    // 기본 스타일은 기본 messageLabel의 Typography값으로 전체는 원 상태 유지
    let base = Typography.attributed(
      fullText,
      style: .bodyLg(weight: .regular),
      color: .gray500
    )
    // 스타일을 변경해주어야 하니 "가변"상태로 변경
    let m = NSMutableAttributedString(attributedString: base)

    // 원하는 일부 부분(target)만 볼드처리
    if let range = fullText.range(of: boldTarget) { // boldTarget 구간만 가져옴
      let ns = NSRange(range, in: fullText) // nsRange로 변환
      // 원하는 구간만 ".bold"로 덮어쓰기 (다른 부분은 수정되지 않고 base상태)
      let boldFont = Typography.font(for: .bodyLg(weight: .bold))
      m.addAttribute(.font, value: boldFont, range: ns) // 가변으로 만들어준 m에다가 내가 원하는 구간(ns)에 bold(boldFont)처리를 해서 주입
    }
    return m
  }
}
