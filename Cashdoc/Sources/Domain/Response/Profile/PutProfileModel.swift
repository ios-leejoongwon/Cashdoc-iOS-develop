//
//  PutProfileModel.swift
//  Cashdoc
//
//  Created by Cashwalk on 2022/05/04.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation

struct PutAccountModel: Codable {
    let result: PutAccountResultModel
}

struct PutAccountResultModel: Codable {
    let pushId: String?
    let kcbAuth: Int?
    let kcbName: String?
    let lastLoginIp: String?
    let nickname: String?
    let gender: String?
    let kcbCellPhone: String?
    let kcbGender: Int?
    let createdAt: Int?
//    let deleted: Bool?
    let lastLoginTime: Int?
    let kcbRegCode: String?
    let name: String?
    let kcbDI: String?
    let code: String?
    let email: String?
    let kcbBirth: String?
    let birth: String?
    let id: String?
    let profileUrl: String?
    let friendCount: Int?
    let point: Int?
    let authPhone: Int?
    let badgeCount: Int?
    var privacyInformationAgreed: Bool?
    var sensitiveInformationAgreed: Bool?
    var healthServiceAgreed: Bool?
}
