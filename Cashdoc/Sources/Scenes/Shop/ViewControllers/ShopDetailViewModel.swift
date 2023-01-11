//
//  ShopDetailViewModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 06/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class ShopDetailViewModel {
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    private let navigator: ShopNavigator
    private let useCase: ShopUseCase
    
    // MARK: - Con(De)structor
    
    init(navigator: DefaultShopNavigator, useCase: ShopUseCase) {
        self.navigator = navigator
        self.useCase = useCase
    }
    
}

extension ShopDetailViewModel: ViewModelType {
    
    struct Input {
        let showBuyCompleteView: Observable<ShopBuyItemModel>
        let showNoPointView: Observable<Void>
        let pushShoppingAuthVC: Observable<Void>
        let presentTextviewLink: Observable<URL>
        let presentBlockUserMail: Observable<Void>
        let errorBackButtonTap: ControlEvent<Void>
        let buyError: Driver<Error>
    }
    struct Output {
        let buyErrorMessage: Driver<String>
    }
    
    // MARK: - Internal methods
    
    func transform(input: Input) -> Output {
        input.showBuyCompleteView
            .bind(onNext: { [weak self] (model) in
                guard let self = self else {return}
                self.navigator.showBuyCompleteView(item: model)
            })
            .disposed(by: disposeBag)
        input.showNoPointView
            .bind(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.navigator.showNoPointView()
            })
            .disposed(by: disposeBag)
        input.pushShoppingAuthVC
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.navigator.pushShoppingAuth()
            }
            .disposed(by: disposeBag)
        input.presentTextviewLink
            .bind { [weak self] (url) in
                guard let self = self else {return}
                self.navigator.presentTextviewLink(url: url)
            }
            .disposed(by: disposeBag)
        input.presentBlockUserMail
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.navigator.presentBlockUserMailCompose()
            }
            .disposed(by: disposeBag)
        input.errorBackButtonTap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.navigator.popViewController()
            }
            .disposed(by: disposeBag)
        
        let buyErrorMessage: Driver<String> = input.buyError
            .flatMapLatest { (error) in
                
                enum ErrorType: Int {
                    case update = 124
                    case list = 227
                    case transaction = 400
                    case point = 10201
                    case limit = 403
                    case close = 404
                    case auth = 322
                    case banned = 500
                    case blocked = 501
                    case other
                }
                
                var message: String
                let errorType = ErrorType(rawValue: error.code) ?? .other
                switch errorType {
                case .update:
                    message = "최신버전으로 업데이트 하셔야 포인트 적립이 가능합니다."
                case .list:
                    message = "쇼핑 리스트를 불러오는 중 오류가 발생했습니다."
                case .transaction:
                    message = "일시적인 오류가 발생하였습니다. 문제가 지속되면 설정의 불편사항 신고하기로 문의 남겨주시기 바랍니다."
                case .point:
                    message = "포인트가 부족합니다."
                case .limit:
                    message = "아쉽게도 오늘은 마감되었어요. 내일 다시 시도해주세요."
                case .close:
                    message = "쇼핑이용 가능시간이 지났어요.\n가능시간:평일 오전10시~오후7시"
                case .auth:
                    message = "그냥사용해보기로 사용중이신 경우 휴대폰 번호 인증이 필요합니다. 최초 1회만 인증하시면 계속 편하게 쇼핑을 이용하실 수 있습니다."
                case .banned, .blocked:
                    message = "bannedAndblocked"
                default:
                    message = "서버 에러로 인해 구매 할 수 없습니다."
                }
                return Driver.just(message)
        }
        
        return Output(buyErrorMessage: buyErrorMessage)
    }
    
    func getItemDetail(by goodsId: String) -> Driver<ShopItemModel> {
        return self.useCase.getItemDetail(goodsId: goodsId)
    }
    
    func buyItem(goodsId: String, onError: @escaping ((Error) throws -> Void)) -> Driver<ShopBuyItemModel?> {
        return self.useCase.postItem(goodsId: goodsId, onError: onError)
    }

}
