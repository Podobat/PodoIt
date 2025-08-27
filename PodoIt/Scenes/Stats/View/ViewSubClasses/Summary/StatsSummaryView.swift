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
  // 더미데이터
  struct DummyStatsData: Hashable {
    let icon: String
    let title: String
    let stats: String
  }

  let dummyStats: [DummyStatsData] = [
    DummyStatsData(icon: "🔥", title: "공부", stats: "1시간 5분"),
    DummyStatsData(icon: "💻", title: "개발", stats: "1시간 40분"),
    DummyStatsData(icon: "🦊", title: "운동", stats: "1시간 1분"),
    DummyStatsData(icon: "🐶", title: "산책", stats: "55분"),
    DummyStatsData(icon: "🐤", title: "강의 듣기", stats: "1시간 33분"),
    DummyStatsData(icon: "🍇", title: "포도 먹기", stats: "5분"),
  ]

  // MARK: - Metrics

  private enum Layout {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 16
    static let summaryPadding: CGFloat = 16
  }

  // MARK: - Properties

  private let disposeBag = DisposeBag()

  private let container = PaddedContainerView(horizontal: Layout.horizontalPadding, vertical: Layout.verticalPadding).then {
    $0.backgroundColor = .gray100
  }

  private let summaryContainer = PaddedContainerView(horizontal: Layout.summaryPadding, vertical: Layout.summaryPadding).then {
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

  // 컬렉션 뷰
  private lazy var collectionView: UICollectionView = {
    // 레이아웃 항목 구성
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(36) // 셀 높이 고정
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    // 그룹 구성
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(36) // 예상 높이 설정
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item]
    )

    // 섹션 구성
    let section = NSCollectionLayoutSection(group: group)

    // 레이아웃 구성
    let layout = UICollectionViewCompositionalLayout(section: section)
    let collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: layout
    )
    collectionView.register(
      StatsCollectionViewCell.self,
      forCellWithReuseIdentifier: StatsCollectionViewCell.reuseIdentifier
    )
    collectionView.isScrollEnabled = false
    collectionView.backgroundColor = .clear
    return collectionView
  }()

  // 컬렉션 뷰 데이터 소스
  private lazy var dataSource = makeDataSource(collectionView)

  // 높이를 제약할 변수
  private var collectionViewHeightConstraint: Constraint?

  private lazy var vStack = UIStackView(arrangedSubviews: [segmentedControl, totalTimeLabel, collectionView]).then {
    $0.axis = .vertical
    $0.distribution = .equalSpacing
    $0.alignment = .center
    $0.spacing = 16
  }

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
    collectionViewSetup()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - ConfigureUI

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

    collectionView.snp.makeConstraints {
      // 초기값 0으로 설정, 나중에 계산해서 업데이트
      collectionViewHeightConstraint = $0.height.equalTo(0).constraint
      $0.directionalHorizontalEdges.equalToSuperview()
    }
  }

  // MARK: - CollectionView Setup

  // 컬렉션뷰에 데이터를 적용하는 함수
  private func collectionViewSetup() {
    var snapshot = NSDiffableDataSourceSnapshot<Int, DummyStatsData>()
    snapshot.appendSections([0]) // 단일 섹션
    snapshot.appendItems(dummyStats) // 더미데이터 적용
    dataSource.apply(snapshot, animatingDifferences: false)
    // 셀 높이 계산
    updateCollectionViewHeight()
  }

  // DiffableDataSource를 생성하는 함수
  private func makeDataSource(_ collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<Int, DummyStatsData> {
    return UICollectionViewDiffableDataSource<Int, DummyStatsData>(
      collectionView: collectionView
    ) { collectionView, indexPath, item in
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: StatsCollectionViewCell.reuseIdentifier,
        for: indexPath
      ) as? StatsCollectionViewCell else {
        return UICollectionViewCell()
      }
      cell.configure(icon: item.icon, title: item.title, stats: item.stats)
      return cell
    }
  }

  // 셀 높이 계산 함수
  private func updateCollectionViewHeight() {
    let cellHeight: CGFloat = 36 // 셀 높이
    let totalHeight = CGFloat(dummyStats.count) * cellHeight
    collectionViewHeightConstraint?.update(offset: totalHeight)
    // 레이아웃 반영
    layoutIfNeeded()
  }

  // MARK: - Bind

  private func bind() {
    segmentedControl.tapIndexRelay
      .subscribe(onNext: { index in
        print("index: \(index)")
      })
      .disposed(by: disposeBag)
  }
}
