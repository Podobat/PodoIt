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
  // MARK: - Metrics

  private enum Layout {
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 16
    static let summaryPadding: CGFloat = 16
    static let totalTimeContainerPadding: CGFloat = 16
    static let totalTimeStackViewSpacing: CGFloat = 8
  }

  // MARK: - Properties

  private let disposeBag = DisposeBag()

  // 세그 선택 인덱스(0=일간, 1=월간) 외부로 전달
  var segmentIndexChanged: Observable<Int> { segmentedControl.tapIndexRelay.asObservable() }

  private let container = PaddedContainerView(horizontal: Layout.horizontalPadding, vertical: Layout.verticalPadding).then {
    $0.backgroundColor = .gray100
  }

  private let summaryContainer = PaddedContainerView(horizontal: Layout.summaryPadding, vertical: Layout.summaryPadding).then {
    $0.backgroundColor = .appWhite
    $0.layer.cornerRadius = 16
  }

  private let segmentedControl = StatsCustomSegmentedControl(items: ["일간", "월간"])
  
  private let emptyView = UIView().then {
    $0.backgroundColor = .appWhite
    $0.isHidden = true
  }
  
  private let emptyLabel = UILabel().then {
    $0.textAlignment = .center
    $0.numberOfLines = 0
    $0.text = "이 날에는 기록된\n집중 시간이 없어요."
    $0.font = Typography.font(for: .bodyLg(weight: .regular))
    $0.textColor = .gray400
    $0.lineBreakMode = .byWordWrapping
  }

  private let totalTimeTotalLabel = UILabel.makeAttributed(
    text: "총", style: .headingMd, color: .gray500, alignment: .left
  )

  // 총 집중 시간 텍스트
  private let totalTimeLabel = UILabel.makeAttributed(
    text: "2시간 50분", style: .headingLg, color: .primary600, alignment: .left
  )

  private let totalTimeFocusLabel = UILabel.makeAttributed(
    text: "집중했어요!", style: .headingMd, color: .gray500, alignment: .left
  )

  private lazy var totalTimeStackView = UIStackView(arrangedSubviews: [totalTimeTotalLabel, totalTimeLabel, totalTimeFocusLabel]).then {
    $0.axis = .horizontal
    $0.spacing = Layout.totalTimeStackViewSpacing
    $0.alignment = .center
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

  private lazy var vStack = UIStackView(arrangedSubviews: [segmentedControl, emptyView, totalTimeStackView, collectionView]).then {
    $0.axis = .vertical
    $0.alignment = .center
    $0.spacing = 16
  }

  // MARK: - Init

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
//    collectionViewSetup()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Override

  override func layoutSubviews() {
    super.layoutSubviews()
    summaryContainer.layoutIfNeeded()

    let path = UIBezierPath(
      roundedRect: CGRect(origin: .zero, size: summaryContainer.bounds.size),
      cornerRadius: summaryContainer.layer.cornerRadius
    ).cgPath
    summaryContainer.layer.shadowPath = path
    summaryContainer.layer.shadowColor = UIColor.appBlack.cgColor // Shadow 색상
    summaryContainer.layer.shadowOpacity = 0.08 // Shadow 불투명도 8%
    summaryContainer.layer.shadowRadius = 16 // Shadow 블러
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
    emptyView.addSubview(emptyLabel)
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
    
    emptyView.snp.makeConstraints {
      $0.height.equalTo(106)
      $0.directionalHorizontalEdges.equalToSuperview()
    }
    
    emptyLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }

  // MARK: - CollectionView Setup

  // DiffableDataSource를 생성하는 함수
  private func makeDataSource(_ collectionView: UICollectionView)
    -> UICollectionViewDiffableDataSource<Int, StatsSummaryModel>
  {
    UICollectionViewDiffableDataSource<Int, StatsSummaryModel>(
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
  private func updateCollectionViewHeight(itemCount: Int) {
    let cellHeight: CGFloat = 36
    collectionViewHeightConstraint?.update(offset: CGFloat(itemCount) * cellHeight)
    layoutIfNeeded()
  }

  // 외부에서 리스트/총합 주입
  func apply(items: [StatsSummaryModel], totalTimeText: String, isDaily: Bool) {
    // 합계 텍스트
    totalTimeLabel.text = totalTimeText

    // 리스트 스냅샷
    var snapshot = NSDiffableDataSourceSnapshot<Int, StatsSummaryModel>()
    snapshot.appendSections([0])
    snapshot.appendItems(items)
    dataSource.apply(snapshot, animatingDifferences: false)

    // 컬렉션뷰 높이 갱신
    updateCollectionViewHeight(itemCount: items.count)

    // 보여줄 섹션 토글
    let hasData = !items.isEmpty
    totalTimeStackView.isHidden = !hasData
    collectionView.isHidden = !hasData
    emptyView.isHidden = hasData

    // empty 라벨 텍스트/폰트 토글
    if !hasData {
      if isDaily {
        // 일간
        emptyLabel.text = "이 날에는 기록된\n집중 시간이 없어요."
        emptyLabel.font = Typography.font(for: .bodyLg(weight: .regular))
      } else {
        // 월간
        emptyLabel.text = "이 달에는 기록된\n집중 시간이 없어요."
        emptyLabel.font = Typography.font(for: .bodyLg(weight: .semibold))
      }
    }
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
