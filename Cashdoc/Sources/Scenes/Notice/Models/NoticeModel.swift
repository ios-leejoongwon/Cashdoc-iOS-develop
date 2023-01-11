//
//  NoticeModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/15.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

struct NoticeModels: Codable {
    let result: [NoticeModel]?
}

// 기존 돈퀴 배너 및 캐닥 배너
struct NoticeModel: Codable {
    let date: String?
    let endDate: String?
    let id: String?
    let image: String?
    let linkType: Int?
    let order: Int?
    let os: String?
    let situation: String?
    let startDate: String?
    let state: Int?
    let subType: String?
    let title: String?
    let type: String?
    var url: String?
    let urlType: String?
}
  
