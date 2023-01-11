//
//  CertificateManager.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/08.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

final class CertificateManager {
    
    class func pushModuleCertificate(currentVC: UIViewController,
                                     exitVoid: (() -> Void)?) {
        
        GlobalDefine.shared.exitClosure = exitVoid
        
        if SmartAIBManager.findCertInfoList().count > 0 {
            pushToLinkPropertyLoginViewController(currentVC: currentVC,
                                                  linkType: .한번에연결,
                                                  propertyType: .ALL,
                                                  bankInfo: BankInfo(bankName: "",
                                                                     isLinked: false,
                                                                     isCanLogin: false))
        } else {
            pushToImportCertViewController(vc: currentVC)
        }
    }
    
    private class func pushToImportCertViewController(vc: UIViewController) {
        let navigator = DefaultPropertyNavigator(parentViewController: vc)
        let vc = ImportCertificateViewController(viewModel: .init(navigator: navigator))
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    private class func pushToLinkPropertyLoginViewController(currentVC: UIViewController,
                                                             linkType: HowToLinkType,
                                                             propertyType: LinkPropertyChildType,
                                                             bankInfo: BankInfo) {
        
        let navigator = DefaultPropertyNavigator(parentViewController: currentVC)
        let vc = LinkPropertyLoginViewController(linkType: linkType,
                                                 bankInfo: bankInfo)
        
        vc.selectCertificateVC = SelectCertificateViewController(viewModel: .init(navigator: navigator),
                                                                 propertyType: propertyType,
                                                                 bankName: bankInfo.bankName)
        vc.loginForCertificateVC = LoginForCertificateViewController(viewModel: .init(navigator: navigator),
                                                                     propertyType: propertyType,
                                                                     bankName: bankInfo.bankName)
        
        if currentVC is HowToImportCertificateViewController {
            GlobalDefine.shared.curNav?.popViewController(animated: false)
            GlobalDefine.shared.curNav?.popViewController(animated: false)
        }
        GlobalFunction.pushVC(vc, animated: true)
    }
    
}
