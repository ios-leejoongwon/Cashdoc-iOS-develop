//
//  User.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

public struct User: Codable {
    let id: String
    var nickname: String
    let email: String?
    let createdAt: Int?
    let lastLoginTime: Int?
    let lastLoginIp: String?
    var point: Int?
    let profileUrl: String?
    var gender: String?
    var birth: String?
    let code: String
    let friendCount: Int?
    let badgeCount: Int?
//    let abuser: Nummber?
    let authPhone: Bool?
    let pushId: String?
    var remainPoint: Int
    let rulletteRemainCnt: Int
    var privacyInformationAgreed: Bool?
    var sensitiveInformationAgreed: Bool?
    var healthServiceAgreed: Bool?
}
