//
//  DummyService.swift
//  RxSwiftPagination
//
//  Created by Ferhan Akkan on 11.07.2021.
//

import Foundation

struct DummyServiceResponse {
    let maxPage: Int
    let hasMore: Bool
    let datas: [String]?
}

struct DummyService {
    
    private let maxPage = 5
    
    func fetchDatas(page: Int, completion: @escaping (DummyServiceResponse) -> ()) {
        if page > maxPage {
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                completion(DummyServiceResponse(maxPage: maxPage,
                                                hasMore: false,
                                                datas: nil))
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                completion(DummyServiceResponse(maxPage: maxPage,
                                                hasMore: page != maxPage,
                                                datas: ["a","b","c","d","e","f","g"]))
            }
        }
    }
}
