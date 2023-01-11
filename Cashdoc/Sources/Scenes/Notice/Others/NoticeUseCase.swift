//
//  NoticeUseCase.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/16.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift

final class NoticeUseCase {
     
    private let provider = CashdocProvider<NoticeService>()
     
    var returnModel: (([NoticeModel]) -> Void)?
    
    func requestNotice(_ complete: @escaping (([NoticeModel]) -> Void)) {
        returnModel = complete
        var noticeModels = [NoticeModel]()
        self.provider.CDRequest(.getNotice) { (json) in
            if let result = try? JSONDecoder().decode(NoticeModels.self, from: json.rawData()) {
                noticeModels.append(contentsOf: result.result ?? [])
                self.returnModel?(noticeModels)
            } else {
            }
        }
    }
    
    func requestOnlyWalkNotice(_ complete: @escaping (([NoticeModel]) -> Void)) {
        returnModel = complete
        self.requestCashWalkNotice()
    }
    
    func requestCashWalkNotice() {
        var noticeModels = [NoticeModel]()
        self.provider.CDRequest(.getCashwalkNotice) { (json) in
            if let result = try? JSONDecoder().decode(NoticeModels.self, from: json.rawData()) {
                if let results = result.result {
                    for var getModel in results {
                        // 퀴즈인것만 가져옴
                        if let getURL = getModel.url {
                            if getURL.hasPrefix("inner://quiz?") {
                                let makeSepa = getURL.split(separator: "=")
                                getModel.url = "cdapp://?quiz=\(makeSepa.last ?? "")"
                                noticeModels.append(getModel)
                            }
                        }
                    }
                    if noticeModels.count > 0 {
                        let ids = noticeModels.compactMap { $0.id }
                        self.postPopupNoticeLog(ids: ids, type: .load)
                    }
                    
                    self.returnModel?(noticeModels)
                }
            }
        }
    }
    
    func postPopupNoticeLog(ids: [String], type: NoticeType) {
        self.provider.CDRequest(.postNoticeLog(ids: ids, type: type)) { (_) in }
    }
}
