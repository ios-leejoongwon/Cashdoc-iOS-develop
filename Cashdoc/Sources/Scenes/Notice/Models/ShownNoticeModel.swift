//
//  ShownNoticeModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/15.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

struct ShownNoticeModel: Codable {
    let id: String
    let showDate: Date
}

extension ShownNoticeModel: Hashable {}
