//
//  DefaultApiResponse.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 10/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

struct DefaultApiResponse<T: Decodable>: Decodable {
    let result: T
    let error: ErrorModel?
}

struct ErrorModel: Decodable {
    let code: Int?
    let type: String?
    let message: String?
}
