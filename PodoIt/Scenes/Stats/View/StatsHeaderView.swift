//
//  StatsHeaderView.swift
//  PodoIt
//
//  Created by 김이든 on 8/23/25.
//

import SnapKit
import Then
import UIKit

final class StatsHeaderView: UIView {
  private enum Layout {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 16
  }

  private let container = PaddedContainerView(horizontal: Layout.horizontalPadding, vertical: Layout.verticalPadding).then {
    $0.backgroundColor = .appWhite
  }

  private let titleLabel = UILabel.makeAttributed(
    text: "통계", style: .headingLg, color: .appBlack, alignment: .left
  )

  private let testButton = UIButton(type: .system).then {
    // 타이틀
    $0.setTitle("전체", for: .normal)
    $0.titleLabel?.font = Typography.font(for: .labelMd(weight: .medium))
    $0.setTitleColor(.gray700, for: .normal)
    // 버튼 style
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = 8
    $0.clipsToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.gray100.cgColor
    // 버튼 내부 패딩
    $0.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 8)
    // 버튼 이미지 설정
    let image = UIImage(named: "chevron-down")?.withRenderingMode(.alwaysTemplate)
    $0.setImage(image, for: .normal)
    $0.tintColor = .gray600
    // 텍스트 오른쪽, 이미지 왼쪽 기본 동작을 반대로
    $0.semanticContentAttribute = .forceRightToLeft
    // 텍스트와 이미지 간 간격
    $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
  }

  private lazy var hStack = UIStackView(arrangedSubviews: [titleLabel, testButton]).then {
    $0.axis = .horizontal
    $0.distribution = .equalSpacing
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureUI() {
    setupView()
    setupConstraints()
  }

  private func setupView() {
    [container].forEach { addSubview($0) }
    [hStack].forEach { container.contentView.addSubview($0) }
  }

  private func setupConstraints() {
    container.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    hStack.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
