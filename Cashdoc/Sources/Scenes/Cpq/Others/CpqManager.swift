//
//  CpqManager.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class CpqManager {
    
    static var shared: CpqManager = .init()
    
    // MARK: - Properties
    
    let cpqListModels: ReplaySubject<CpqListModels?> = ReplaySubject.create(bufferSize: 1)
    let cpqListQuizModels: ReplaySubject<CpqQuizModel?> = ReplaySubject.create(bufferSize: 1)
    let cpqAnswerPointModel: ReplaySubject<CpqAnswerPointModel?> = ReplaySubject.create(bufferSize: 1)
    
    #if CASHWALK
    private let cpqService = CashwalkProvider<CpqService>()
    #else
    private let cpqService = CashdocProvider<CpqService>()
    #endif
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Internal methods
    
    func getCpqList(live: Int?, lastDate: String?, completion: ((Error?, CpqListModels?) -> Void)? = nil) {
        _ = cpqService.request(CpqListResultModels.self, token: .getCpqList(live: live, lastDate: lastDate))
            .subscribe(onSuccess: { [weak self] (list) in
                guard let self = self else { return }
                self.cpqListModels.onNext(list.result)
                completion?(nil, list.result)
                }, onFailure: { error in
                    completion?(error, nil)
                    Log.e(error)
                }).disposed(by: disposeBag)
    }
    
    func getCpqQuizList(id: String, completion: ((Error?, CpqQuizModel?) -> Void)? = nil) {
        _ = cpqService.request(CpqQuizResultModels.self, token: .getCpqQuizList(id: id))
            .subscribe(onSuccess: { [weak self] (list) in
                guard let self = self else { return }
                self.cpqListQuizModels.onNext(list.result)
                completion?(nil, list.result)
                }, onFailure: { error in
                    completion?(error, nil)
                    Log.e(error)
            }).disposed(by: disposeBag)
    }
    
    func postAnswer(quizId: String, questionId: String, answer: String, deviceId: String, completion: ((Error?, CpqAnswerPointModel?) -> Void)? = nil) {
        _ = cpqService.request(CpqAnswerResultModel.self, token: .postAnswer(quizId: quizId, questionId: questionId, answer: answer, deviceId: deviceId))
            .subscribe(onSuccess: { [weak self] (result) in
                guard let self = self else { return }
                self.cpqAnswerPointModel.onNext(result.result)
                completion?(nil, result.result)
                }, onFailure: { error in
                    completion?(error, nil)
                    Log.e(error)
            }).disposed(by: disposeBag)
    }
}
