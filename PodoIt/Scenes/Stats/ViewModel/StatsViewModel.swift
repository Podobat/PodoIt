//
//  StatsViewModel.swift
//  PodoIt
//
//  Created by 김이든 on 9/2/25.
//

import Foundation
import RxCocoa
import RxSwift

protocol StatsRepository {
  func fetchDistinctCategories() throws -> [StatsCategoryModel]
}

final class StatsViewModel {
  // Outputs
  let categories = BehaviorRelay<[StatsCategoryModel]>(value: [.all])
  let selectedCategory = BehaviorRelay<StatsCategoryModel>(value: .all)
  let errorMessage = PublishRelay<String>()

  private let repo: StatsRepository
  private let disposeBag = DisposeBag()

  init(repo: StatsRepository = SwiftDataManager.shared) {
    self.repo = repo

    NotificationCenter.default.rx.notification(.statsDidChange)
      .subscribe(onNext: { [weak self] _ in
        self?.reloadCategories()
      })
      .disposed(by: disposeBag)
  }

  // Input: 화면 최초 로드 시 호출
  func viewDidLoad() {
    do {
      let list = try repo.fetchDistinctCategories()
      categories.accept(list.isEmpty ? [.all] : list)
      // 초기 선택값은 항상 .all
      selectedCategory.accept(.all)
    } catch {
      errorMessage.accept("카테고리를 불러오지 못했습니다.")
    }
  }

  // Input: 시트에서 항목 선택 시 호출
  func didSelect(category: StatsCategoryModel) {
    selectedCategory.accept(category)
  }
  
  // 카테고리 갱신
  private func reloadCategories() {
    do {
      let list = try repo.fetchDistinctCategories()
      categories.accept(list.isEmpty ? [.all] : list)
      if !categories.value.contains(selectedCategory.value) {
        selectedCategory.accept(.all)
      }
    } catch {
      errorMessage.accept("카테고리를 불러오지 못했습니다.")
    }
  }
}
