//
//  Clousures.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 06/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Alamofire

// typealias AlamofireCompletionHandler = (DataResponse<Any>) -> Void
typealias CompletionHandler = (Any) -> Void
typealias SimpleCompletion = () -> Void
typealias ErrorCompletion = (NSError?) -> Void
