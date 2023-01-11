//
//  ConsumeDataModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 28/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

struct ConsumeDataModel: Codable {
    var identity: String
    var consumeType: String
    var category: String
    let subCategory: String
    var touchCount: Int
    var isTouchEnabled: Bool
    var isDeleted: Bool
    let categoryImageName: String
    var title: String
    var subTitle: String
    var income: Int
    var outgoing: Int
    let originalPrice: Int
    var date: String
    var time: String
    var cardName: String
    var memo: String
    
    var cardPaymentType: String
    var cardApprovalGuBun: String
    var cardPaymentTerm: String
    var approvalNum: String
    
    var tranBal: Int
    var tranGb: String
    
    init() {
        self.identity =  ""
        self.consumeType = "카드"
        self.category = ""
        self.subCategory = ""
        self.touchCount = 0
        self.isTouchEnabled = false
        self.isDeleted = false
        self.categoryImageName = ""
        self.title = ""
        self.subTitle = ""
        self.income = 0
        self.outgoing = 0
        self.originalPrice = 0
        self.date = ""
        self.time = ""
        self.cardName = ""
        self.memo = ""
        self.cardPaymentType = ""
        self.cardApprovalGuBun = ""
        self.cardPaymentTerm = ""
        self.approvalNum = ""
        self.tranBal = 0
        self.tranGb = ""
    }
    
    init(identity: String,
         consumeType: String,
         category: String,
         subCategory: String,
         touchCount: Int,
         isTouchEnabled: Bool,
         isDeleted: Bool,
         categoryImageName: String,
         title: String,
         subTitle: String,
         income: Int,
         outgoing: Int,
         originalPrice: Int,
         date: String,
         time: String,
         cardName: String,
         memo: String,
         cardPaymentType: String,
         cardApprovalGuBun: String,
         cardPaymentTerm: String,
         approvalNum: String,
         tranBal: Int,
         tranGb: String) {
        self.identity =  identity
        self.consumeType = consumeType
        self.category = category
        self.subCategory = subCategory
        self.touchCount = touchCount
        self.isTouchEnabled = isTouchEnabled
        self.isDeleted = isDeleted
        self.categoryImageName = categoryImageName
        self.title = title
        self.subTitle = subTitle
        self.income = income
        self.outgoing = outgoing
        self.originalPrice = originalPrice
        self.date = date
        self.time = time
        self.cardName = cardName
        self.memo = memo
        self.cardPaymentType = cardPaymentType
        self.cardApprovalGuBun = cardApprovalGuBun
        self.cardPaymentTerm = cardPaymentTerm
        self.approvalNum = approvalNum
        self.tranBal = tranBal
        self.tranGb = tranGb
    }
    
    init?(list: CheckCardApprovalDetailsList) {
        let category = list.category
        let subCategory = list.subCategory
        let image = CategoryManager.findOutgoingCategoryImage(with: subCategory)
        var tranGb = "입금"
        if category != "수입" {
            tranGb = "출금"
        }
        self.identity = list.appNo
        self.consumeType = "카드"
        self.category = category
        self.subCategory = subCategory
        self.touchCount = list.touchCount
        self.isTouchEnabled = list.isTouchEnabled
        self.isDeleted = list.isDeleted
        self.categoryImageName = image
        self.title = list.appFranName
        self.subTitle = list.appNickname
        self.income = list.appAmt
        self.outgoing = list.appAmt
        self.originalPrice = list.originalAppAmt
        self.date = list.appDate.simpleDateFormat("yyyyMMdd")
        self.time = list.appTime
        self.cardName = list.appNickname
        self.memo = list.memo
        self.cardPaymentType = list.useDis
        self.cardApprovalGuBun = list.appGubun
        self.cardPaymentTerm = list.appQuota
        self.approvalNum = list.appNo
        self.tranBal = 0
        self.tranGb = tranGb
    }
    
    init?(list: CheckAccountTransactionDetailsList, subName: String) {
        var original = list.originalPrice
        var category = list.category
        var subCategory = list.subCategory
        if list.outBal == 0 {
            subCategory = list.subCategory
            category = list.category
            original = list.inBal
        }
        let imageName = CategoryManager.findEtcCategoryImage(with: subCategory)
        self.identity = list.identity
        self.consumeType = "계좌"
        self.category = category
        self.subCategory = subCategory
        self.touchCount = list.touchCount
        self.isTouchEnabled = list.isTouchEnabled
        self.isDeleted = list.isDeleted
        self.categoryImageName = imageName
        self.title = list.jukyo
        self.subTitle = subName
        self.income = list.inBal
        self.outgoing = list.outBal
        self.originalPrice = original
        self.date = list.tranDate.simpleDateFormat("yyyyMMdd")
        self.time = list.tranDt
        self.cardName = list.tranDep
        self.memo = list.memo
        self.cardPaymentType = "일시불"
        self.cardApprovalGuBun = "승인"
        self.cardPaymentTerm = "0"
        self.approvalNum = "0"
        self.tranBal = list.tranBal
        self.tranGb = list.tranGb
    }
    
    init?(list: ManualConsumeList) {
        let category = list.category
        let subCategory = list.subCategory
        var image = "icQuestionMarkBlack"
        if category == "기타" {
            image = CategoryManager.findEtcCategoryImage(with: subCategory)
        } else if category == "수입" {
            image = CategoryManager.findIncomeCategoryImage(with: subCategory)
        } else if category == "지출" {
            image = CategoryManager.findOutgoingCategoryImage(with: subCategory)
        }
        self.identity = list.identity
        self.consumeType = "수기"
        self.category = category
        self.subCategory = subCategory
        self.touchCount = list.touchCount
        self.isTouchEnabled = list.isTouchEnabled
        self.isDeleted = list.isDeleted
        self.categoryImageName = image
        self.title = list.contents
        self.subTitle = list.expedient
        self.income = list.income
        self.outgoing = list.outgoing
        self.originalPrice = 0
        self.date = list.date.simpleDateFormat("yyyyMMdd")
        self.time = list.time
        self.cardName = list.expedient
        self.memo = list.memo
        self.cardPaymentType = "일시불"
        self.cardApprovalGuBun = "승인"
        self.cardPaymentTerm = "0"
        self.approvalNum = "0"
        self.tranBal = 0
        self.tranGb = list.gb
    }
}
