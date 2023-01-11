//
//  ShopService.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 21/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum ShopService {
    case getCategory
    case getItemDetail(goodsId: String)
    case getItemList(listId: String)
    case postItem(goodsId: String)
}

// MARK: - TargetType

extension ShopService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .getCategory:
            return "shop/category"
        case .getItemDetail(let goodsId):
            return "shop/detail/\(goodsId)"
        case .getItemList(let listId):
            return "shop/list/\(listId)"
        case .postItem:
            return "shop"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCategory, .getItemList:
            return .get
        case .getItemDetail:
            return .get
        case .postItem:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .getCategory:
            parameters["access_token"] = AccessTokenManager.accessToken
        case .getItemDetail(let goodsId):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["goodsId"] = goodsId
        case .getItemList:
            parameters["access_token"] = AccessTokenManager.accessToken
        case .postItem(let goodsId):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["goodsId"] = goodsId
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
