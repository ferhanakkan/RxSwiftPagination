//
//  PaginationViewModel.swift
//  RxSwiftPagination
//
//  Created by Ferhan Akkan on 11.07.2021.
//

import Foundation
import RxCocoa
import RxSwift

final class PaginationViewModel {
    
    private let disposeBag = DisposeBag()
    private let dummyService = DummyService()

    let items = BehaviorRelay<[String]>(value: [])

    let fetchMoreDatas = PublishSubject<Void>()
    let refreshControlAction = PublishSubject<Void>()
    let refreshControlCompelted = PublishSubject<Void>()
    let isLoadingSpinnerAvaliable = PublishSubject<Bool>()

    private var pageCounter = 1
    private var maxValue = 1
    private var isPaginationRequestStillResume = false
    private var isRefreshRequstStillResume = false
    
    init() {
        bind()
    }

    private func bind() {

        fetchMoreDatas.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.fetchDummyData(page: self.pageCounter,
                                isRefreshControl: false)
        }
        .disposed(by: disposeBag)

        refreshControlAction.subscribe { [weak self] _ in
            self?.refreshControlTriggered()
        }
        .disposed(by: disposeBag)
    }

    private func fetchDummyData(page: Int, isRefreshControl: Bool) {
        if isPaginationRequestStillResume || isRefreshRequstStillResume { return }
        self.isRefreshRequstStillResume = isRefreshControl
        
        if pageCounter > maxValue  {
            isPaginationRequestStillResume = false
            return
        }
       
        isPaginationRequestStillResume = true
        isLoadingSpinnerAvaliable.onNext(true)
        
        if pageCounter == 1  || isRefreshControl {
            isLoadingSpinnerAvaliable.onNext(false)
        }
        
        // For your real service you have to handle fail status.
        dummyService.fetchDatas(page: page) { [weak self] dummyResponse in
            self?.handleDummyData(data: dummyResponse)
            self?.isLoadingSpinnerAvaliable.onNext(false)
            self?.isPaginationRequestStillResume = false
            self?.isRefreshRequstStillResume = false
            self?.refreshControlCompelted.onNext(())
        }
    }

    private func handleDummyData(data: DummyServiceResponse) {

        maxValue = data.maxPage
        if pageCounter == 1, let finalData = data.datas {
            self.maxValue = data.maxPage
            items.accept(finalData)
        } else if let data = data.datas {
            let oldDatas = items.value
            items.accept(oldDatas + data)
        }
        pageCounter += 1
    }

    private func refreshControlTriggered() {
//        moviesAPI.cancelAllRequests() For your network request you have to cancel previous requests. Alamofire has a function to cancel all reuqests.
        isPaginationRequestStillResume = false
        pageCounter = 1
        items.accept([])
        fetchDummyData(page: pageCounter,
                       isRefreshControl: true)
    }
}
