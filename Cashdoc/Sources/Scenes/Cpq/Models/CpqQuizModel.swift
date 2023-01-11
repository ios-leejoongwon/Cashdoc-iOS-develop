//
//  CpqQuizModel.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

final class CpqQuizResultModels: Decodable {
    private(set) var result: CpqQuizModel?
}

final class CpqQuizModel: Decodable {
    var winnerList: [CpqWinnerModel]?
    var quiz: CpqQuizListModel?
}

final class CpqWinnerModel: Decodable {
    var point: Int?
    var nickname: String?
    var owner: String?
    var profileUrl: String?
    var created: String?
}

final class CpqQuizListModel: Decodable {
    var id: String?
    var imageUrl: String?
    var youtubeUrl: String?
    var iconImageUrl: String?
    var detailImageUrl: String?
    var keywordImageUrl: String?
    var keyword: String?
    var title: String?
    var total: Int?
    var description: String?
    var lock: Int?
    var participate: Int?
    var demandUrl: String?
    var detail: CpqQuizDetailModel?
}

final class CpqQuizDetailModel: Decodable {
    var id: String?
    var quizId: String?
    var question: String?
    var hint: String?
    var redirectUrl: String?
    var searchBtnText: String?
}
