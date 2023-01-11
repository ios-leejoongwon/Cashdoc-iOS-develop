//
//  PostBillingModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/09.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

struct PostBillingModel: Codable {
    var insured: BillingName = .init()
    var insuredAdditional: BillingFatherName = .init()
    var invoice: BillingInvoice = .init()
    
    init(org: String, date: String,
         amount: String, pName: String,
         fatherName: String? = nil) {
        insuredAdditional.fatherName = fatherName ?? ""
        invoice.org = org
        invoice.date = date.simpleDateFormat("yyyyMMdd").simpleDateFormat("yyyy.MM.dd")
        invoice.amount = amount.commaValue + "원"
        insured.name = pName
    }
}

struct BillingName: Codable {
    var name: String = ""
}

struct BillingFatherName: Codable {
    var fatherName: String = ""
}

struct BillingInvoice: Codable {
    var date: String = ""
    var org: String = ""
    var amount: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case date = "treatment_date"
        case org = "treatment_org"
        case amount = "treatment_amount"
    }
}
