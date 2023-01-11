//
//  MoyaCacheablePlugin.swift
//  Cashdoc
//
//  Created by DongHeeKang on 21/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

final class MoyaCacheablePlugin: PluginType {
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        if let moyaCachableProtocol = target as? MoyaCacheable {
            var cachableRequest = request
            cachableRequest.cachePolicy = moyaCachableProtocol.cachePolicy
            return cachableRequest
        }
        return request
    }
}
