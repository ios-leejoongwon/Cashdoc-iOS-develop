//
//  LinkedScrapingInfo.swift
//  Cashdoc
//
//  Created by Oh Sangho on 01/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
final class LinkedScrapingInfo: Object {
    
    // MARK: - Properties
    
    dynamic var fCodeName: String?
    dynamic var loginType: String?
    dynamic var loginMethodIdValue: String?
    dynamic var loginMethodPwdValue: String?
    dynamic var pIsError: Bool = false
    dynamic var pErrorMsg: String?
    dynamic var pErrorCode: String?
    dynamic var cLinked: Bool = false
    dynamic var cIsError: Bool = false
    dynamic var cErrorMsg: String?
    dynamic var cErrorCode: String?
    dynamic var juminNumber: String?
    
    // MARK: - Con(De)structor
    
    convenience required init(loginMethods: [String: [String: String]]) {
        self.init()
        
        loginMethods.forEach { [weak self] (fCodeName, loginMethod) in
            guard let self = self else { return }
            self.fCodeName = fCodeName
            
            if let certDirectory = loginMethod["CERTDIRECTORY"] {
                self.loginType = "0"
                self.loginMethodIdValue = setCertDirectoryID(with: certDirectory)
                guard let pwd = loginMethod["CERTPWD"] else { return }
                if AES256CBC.decryptCashdoc(pwd) != nil {
                    self.loginMethodPwdValue = pwd
                } else {
                    if let cPwd = AES256CBC.encryptCashdoc(pwd) {
                        self.loginMethodPwdValue = cPwd
                    }
                }
            } else {
                self.loginType = "1"
                self.loginMethodIdValue = loginMethod["LOGINID"] ?? ""
                guard let pwd = loginMethod["LOGINPWD"] else { return }
                if AES256CBC.decryptCashdoc(pwd) != nil {
                    self.loginMethodPwdValue = pwd
                } else {
                    if let cPwd = AES256CBC.encryptCashdoc(pwd) {
                    self.loginMethodPwdValue = cPwd
                    }
                }
            }
        }
        
    }
    
    convenience required init(info: LinkedScrapingInfo,
                              isError: Bool,
                              errorResult: ErrorResult,
                              type: ScrapingType) {
        self.init()
        
        self.loginType = info.loginType
        self.fCodeName = info.fCodeName
        if info.loginType == "0" {
            self.loginMethodIdValue = setCertDirectoryID(with: info.loginMethodIdValue)
        } else {
            self.loginMethodIdValue = info.loginMethodIdValue
        }
        self.loginMethodPwdValue = info.loginMethodPwdValue
        switch type {
        case .가계부:
            self.cLinked = true
            self.cIsError = isError
            if isError {
                self.cErrorMsg = errorResult.errorMsg
                self.cErrorCode = errorResult.errorCode ?? ""
            }
        default:
            self.pIsError = isError
            if isError {
                self.pErrorMsg = errorResult.errorMsg
                self.pErrorCode = errorResult.errorCode ?? ""
            }
        }
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "fCodeName"
    }
    
    // MARK: - Private methods
    
    private func setCertDirectoryID(with certDirectory: String?) -> String {
        guard let certDirectory = certDirectory, certDirectory.isNotEmpty else { return "" }
        var resultCN = ""
        if certDirectory.contains("cn=") {
            guard let tmpCN = certDirectory.components(separatedBy: "cn=").last else {
                return certDirectory
            }
            resultCN = String(format: "cn=%@", tmpCN)
        }
        return resultCN
    }
}
