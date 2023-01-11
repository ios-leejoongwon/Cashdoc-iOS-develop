//
//  CpqAnswerResultModel.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

final class CpqAnswerResultModel: Decodable {
    private(set) var result: CpqAnswerPointModel?
}

final class CpqAnswerPointModel: Decodable {
    var point: Int?
    var pointType: Int?
}
