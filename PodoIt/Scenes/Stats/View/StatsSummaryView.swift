//
//  StatsSummaryView.swift
//  PodoIt
//
//  Created by 김이든 on 8/23/25.
//

import RxCocoa
import RxSwift
import SnapKit
import Then
import UIKit

final class StatsSummaryView: UIView {
  private let disposeBag = DisposeBag()

  private enum Layout {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 16
  }

  private let container = PaddedContainerView(horizontal: Layout.horizontalPadding, vertical: Layout.verticalPadding).then {
    $0.backgroundColor = .gray100
  }

  private let summaryContainer = PaddedContainerView(horizontal: Layout.verticalPadding, vertical: Layout.verticalPadding).then {
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = 16
    $0.clipsToBounds = true
  }

  private let segmentedControl = StatsCustomSegmentedControl(items: ["일간", "월간"])

  private let totalTimeLabel = UILabel().then {
    let fullText = "총 2시간 50분 집중했어요!"
    let attributedString = NSMutableAttributedString(
      string: fullText,
      attributes: [
        .font: Typography.font(for: .headingMd),
        .foregroundColor: UIColor.gray500,
      ]
    )

    // "2시간 50분" 부분의 범위 찾기
    let timeRange = (fullText as NSString).range(of: "2시간 50분")

    // 해당 범위에만 폰트 크기 변경 적용
    attributedString.addAttributes([
      .font: Typography.font(for: .headingLg),
      .foregroundColor: UIColor.appBlack,
    ], range: timeRange)

    $0.attributedText = attributedString
  }

  private lazy var vStack = UIStackView(arrangedSubviews: [segmentedControl, totalTimeLabel]).then {
    $0.axis = .vertical
    $0.distribution = .equalSpacing
    $0.alignment = .center
    $0.spacing = 16
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
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
    [summaryContainer].forEach { container.contentView.addSubview($0) }
    [vStack].forEach { summaryContainer.contentView.addSubview($0) }
  }

  private func setupConstraints() {
    container.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    summaryContainer.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }

    vStack.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }

  private func bind() {
    segmentedControl.tapIndexRelay
      .subscribe(onNext: { index in
        print("index: \(index)")
      })
      .disposed(by: disposeBag)
  }
}
