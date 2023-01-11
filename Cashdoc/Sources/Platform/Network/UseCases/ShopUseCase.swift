//
//  ShopUseCase.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 21/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

class ShopUseCase {
    
    private let provider = CashdocProvider<ShopService>()
    
    func getShopModel() -> Driver<ShopCategoryModelResult> {
        return provider.request(ShopCategoryModelResponse.self, token: .getCategory)
            .asDriverOnErrorJustNever()
            .map {$0.result}
    }
    
    func getShopCategory() -> Driver<[ShopCategoryModel]> {
        return provider.request(ShopCategoryModelResponse.self, token: .getCategory)
            .asDriverOnErrorJustNever()
            .map {$0.result.category!}
    }
    
    func getItemDetail(goodsId: String) -> Driver<ShopItemModel> {
        return provider.request(DefaultApiResponse<ShopItemModel>.self, token: .getItemDetail(goodsId: goodsId))
            .asDriverOnErrorJustNever()
            .map {$0.result}
    }
    
    func getItemList(listId: String) -> Driver<ShopItemModelResponse> {
        return provider.request(ShopItemModelResponse.self, token: .getItemList(listId: listId))
            .asDriverOnErrorJustNever()
            .map {$0}
    }
    
    func postItem(goodsId: String, onError: @escaping ((Error) throws -> Void)) -> Driver<ShopBuyItemModel?> {
        return provider.request(DefaultApiResponse<ShopBuyItemResponse>.self, token: .postItem(goodsId: goodsId))
            .do(onError: onError)
            .asDriverOnErrorJustNever()
            .do { model in 
                GlobalFunction.SendBrEvent(name: "using cash - shopping", properti: ["reward_id": model.result.goodsId ?? "",
                                                                                     "reward_name": model.result.coupon?.title ?? "",
                                                                                     "reward_brand": model.result.coupon?.affiliate ?? "",
                                                                                     "reward_category": model.result.coupon?.ctrId ?? "",
                                                                                     "cash_used": model.result.point?.used ?? 0])
            }
            .map {$0.result.coupon}
    }
}
