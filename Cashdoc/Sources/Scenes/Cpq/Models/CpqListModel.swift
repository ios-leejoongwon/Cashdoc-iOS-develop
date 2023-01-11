//
//  CpqListModel.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//
final class CpqListResultModels: Decodable {
    private(set) var result: CpqListModels?
}

final class CpqListModels: Decodable {
    private(set) var list: [CpqListModel]?
    private(set) var coming: String?
}

final class CpqListModel: Decodable {
    var id: String?
    var beginDate: String?
    var title: String?
    var winner: Int?
    var point: Int?
    var iconImageUrl: String?
    var lock: Int?
    var imageUrl: String?
}
