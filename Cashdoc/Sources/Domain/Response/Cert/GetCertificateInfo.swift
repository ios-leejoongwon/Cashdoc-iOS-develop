//
//  GetCertificateInfo.swift
//  Cashdoc
//
//  Created by Oh Sangho on 07/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct GetCertificateInfo: Decodable {
    let headerArea: HeaderArea
    let bodyArea: BodyArea
    
    private enum CodingKeys: String, CodingKey {
        case headerArea = "HeaderArea"
        case bodyArea = "BodyArea"
    }
}

struct HeaderArea: Decodable {
    let hRstCd: String
    let hRstMsg: String
    
    private enum CodingKeys: String, CodingKey {
        case hRstCd = "H_RST_CD"
        case hRstMsg = "H_RST_MSG"
    }
}

struct BodyArea: Decodable {
    let orgCd: String
    let serviceCd: String
    let certNm: String
    let certPw: String
    let certOrgNm: String
    let certDate: String
    let certPath: String
    let certDerFile: String
    let certKeyFile: String
    
    private enum CodingKeys: String, CodingKey {
        case orgCd = "H_ORG_CD"
        case serviceCd = "H_SERVICE_CD"
        case certNm = "H_CERT_NM"
        case certPw = "H_CERT_PW"
        case certOrgNm = "H_CERT_ORG_NM"
        case certDate = "H_CERT_DATE"
        case certPath = "H_CERT_PATH"
        case certDerFile = "H_CERT_FILE1"
        case certKeyFile = "H_CERT_FILE2"
    }
}
