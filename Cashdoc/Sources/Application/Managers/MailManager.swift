//
//  MailManager.swift
//  Cashdoc
//
//  Created by Oh Sangho on 24/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import MessageUI
import RxSwift

enum MailManager {
    
    // MARK: - Public static func
    
    static func alert(from controller: UIViewController) {
        let cancelAction = UIAlertAction(title: "아니오", style: .cancel) { (_) in
            showMailCompose(to: controller, isInquire: false)
        }
        let okAction = UIAlertAction(title: "예", style: .default) { (_) in
            showMailCompose(to: controller, isInquire: true)
        }
        controller.alert(title: "불편사항 신고하기", message: "", preferredStyle: .alert, actions: [cancelAction, okAction])
    }
    
    static func showMailCompose(to controller: UIViewController, isInquire: Bool) {
        guard isInquire else { return }
        guard MFMailComposeViewController.canSendMail() else {
            let okAction = UIAlertAction(title: "확인", style: .default)
            controller.alert(title: "이메일 설정", message: "아이폰의 기본 이메일 설정 후에 다시 시도해주세요.", preferredStyle: .alert, actions: [okAction])
            return
        }
        controller.present(makeMailComposeViewController(to: controller as? MFMailComposeViewControllerDelegate,
                                                         isInquire: isInquire), animated: true, completion: nil)
    }
    
    static func showMailCompose(to controller: UIViewController, sendmail: [String]) {
        guard MFMailComposeViewController.canSendMail() else {
            let okAction = UIAlertAction(title: "확인", style: .default)
            controller.alert(title: "이메일 설정", message: "아이폰의 기본 이메일 설정 후에 다시 시도해주세요.", preferredStyle: .alert, actions: [okAction])
            return
        }
        controller.present(makeMailComposeViewController(to: controller as? MFMailComposeViewControllerDelegate,
                                                         isInquire: true, editStrings: sendmail), animated: true, completion: nil)
    }
    
    private static func makeMailComposeViewController(to delegate: MFMailComposeViewControllerDelegate?,
                                                      isInquire: Bool, editStrings: [String]? = nil) -> MFMailComposeViewController {
        let subject = makeMailSubject(isInquire, editStrings: editStrings)
        let message = makeMailMessage(isInquire, editStrings: editStrings)
        let controller = CDMailComposeVC()
        controller.mailComposeDelegate = controller
        controller.setToRecipients(getRecipients())
        controller.setSubject(subject)
        controller.setMessageBody(message, isHTML: false)
        return controller
    }
    
    private static func makeMailSubject(_ isInquire: Bool, editStrings: [String]? = nil) -> String {
        var subject = "[불편신고][아이폰]"
        if editStrings?.count ?? 0 > 0 {
            subject = "[수정요청][아이폰]"
        }
        return subject
    }
    
    private static func makeMailMessage(_ isInquire: Bool, editStrings: [String]? = nil) -> String {
        let disposeBag = DisposeBag()
        func getDataMessage() -> Observable<String> {
            return UserManager.shared.user
                .map { (user) in
                    guard let point = user.point,
                        let createdAt = user.createdAt else {return .init()}
                    
                    let makeDate: Date = Date(timeIntervalSince1970: TimeInterval(createdAt))
                    
                    var editMessage = ""
                    if editStrings?.count ?? 0 == 4 {
                        editMessage = """
                        
                        ==수정 기본 정보
                        = 요청 항목 : \(editStrings?[safe: 0] ?? "")
                        = 명칭 : \(editStrings?[safe: 1] ?? "")
                        = 위치 : \(editStrings?[safe: 2] ?? "")
                        = | : \(editStrings?[safe: 3] ?? "")
                        
                        """
                    } else if editStrings?.count ?? 0 == 2 {
                        editMessage = """
                        
                        ==수정 기본 정보
                        = 로또 회차 : \(editStrings?[safe: 0] ?? "")
                        = 등수 : \(editStrings?[safe: 1] ?? "")
                        
                        """
                    }
                    
                    return """
                    본문:
                    
                    
                    
                    
                    
                    = ---- 아래 내용은 수정하지 마세요 ----\(editMessage)
                    = 추천코드: \(user.code)
                    = 핸드폰 모델명: \(UIDevice.current.modelName)
                    = iOS 버전: \(UIDevice.current.systemVersion)
                    = 캐시닥 버전: \(getAppVersion())
                    = P : \(point)
                    = J : \(makeDate.simpleDateFormat("yyyy.MM.dd HH:mm"))
                    """
            }
        }
        
        var message = ""
        
        if isInquire {
            getDataMessage()
                .take(1)
                .subscribe(onNext: { (getMessage) in
                    message = getMessage
                })
                .disposed(by: disposeBag)
        }
        return message
    }
    
    private static func getRecipients() -> [String] {
        return ["cs@cashdoc.me"]
    }
}

class CDMailComposeVC: MFMailComposeViewController, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
