//
//  CpqGuideViewController.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import MessageUI

class CpqGuideViewController: CashdocViewController {
    
    // MARK: - Properties
    
    // MARK: - UI Components
    
    private let navigationBarView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(255, 210, 0)
    }
    private let scrollView = UIScrollView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
    }
    private let cpqTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .blackCw
        $0.numberOfLines = 1
        $0.text = "용돈퀴즈란?"
    }
    private let cpqSubLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor.fromRGB(102, 102, 102)
        $0.numberOfLines = 0
        $0.text = "누구나 퀴즈를 풀고 상금의 일부를 랜덤하게 캐시로 받을 수 있는 서비스입니다."
    }
    private let quizPrizeTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .blackCw
        $0.numberOfLines = 1
        $0.text = "퀴즈상금"
    }
    private let quizPrizeSubLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor.fromRGB(102, 102, 102)
        $0.numberOfLines = 0
        $0.text = "- 정답을 맞히면 상금의 일부를 랜덤하게 캐시로 받을 수 있습니다.\n- 최대 10,000캐시까지 당첨될 수 있습니다.\n- 퀴즈를 푸는 도중에 상금이 모두 소진되면 캐시를 받을 수 없습니다."
    }
    private let precautionsTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .blackCw
        $0.numberOfLines = 1
        $0.text = "주의사항"
    }
    private let precautionsSubLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor.fromRGB(102, 102, 102)
        $0.numberOfLines = 0
        $0.text = "아래의 경우 당첨금 지급을 거부하거나, 임의로 서비스 이용을 제한할 수 있습니다.\n▷ 한 퀴즈의 정답을 반복적으로 수 차례 입력한 경우.\n\n▷ 부정한 방법을 사용하여 당첨금을 중복으로 수령하거나 이를 악용한 경우.\n\n▷ 퀴즈 별 1회만 참여 가능합니다. 참여했었던 퀴즈에 문제가 변경 되더라도 이미 참여한 퀴즈에는 다시 참여할 수 없습니다."
    }
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGrayCw
    }
    private let iconImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "icInquiryYellow")
    }
    private let contactUsTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .blackCw
        $0.numberOfLines = 1
        $0.text = "제휴문의"
    }
    private let contactUsSubLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        $0.textColor = UIColor.fromRGB(102, 102, 102)
        $0.numberOfLines = 0
        $0.text = "제품 및 서비스홍보 목적의 퀴즈등록은 제휴문의를 통해 연락주시면 담당자가 확인 후 연락드릴 예정입니다."
    }
    private let contactUsButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("제휴문의하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.setBackgroundColor(.blackCw, forState: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        //        bindView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: BaseViewController
    
//    override var backButtonTitleHidden: Bool {
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setSelector()
        view.addSubview(scrollView)
        view.addSubview(navigationBarView)
        scrollView.addSubview(cpqTitleLabel)
        scrollView.addSubview(cpqSubLabel)
        scrollView.addSubview(quizPrizeTitleLabel)
        scrollView.addSubview(quizPrizeSubLabel)
        scrollView.addSubview(precautionsTitleLabel)
        scrollView.addSubview(precautionsSubLabel)
        scrollView.addSubview(horizontalLine)
        scrollView.addSubview(contactUsTitleLabel)
        scrollView.addSubview(iconImageView)
        scrollView.addSubview(contactUsSubLabel)
        scrollView.addSubview(contactUsButton)
        layout()
    }
    
    // MARK: - Binding
    
//    private func bindView() {
//
//    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        title = "용돈퀴즈"
        view.backgroundColor = .white
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
    
     private func setSelector() {
        contactUsButton.addTarget(self, action: #selector(didClickedContactUsButton), for: .touchUpInside)
    }
    
    private func presentBlockUserMailCompose() {
        guard MFMailComposeViewController.canSendMail() else {
            let confirmAction = UIAlertAction(title: "확인", style: .default)
            self.alert(title: "이메일 설정", message: "아이폰의 기본 이메일 설정후에 다시 시도해주세요.", preferredStyle: .alert, actions: [confirmAction])
            return
        }
        
        func getMailMessage() -> String {
            let message = """
            아래 양식에 맞춰 작성 해주시면 담당자가 확인 후 빠른 시일내에 연락 드리도록 하겠습니다.

            상호(제품)명 :

            담당자이름 :

            이메일주소 :

            연락처 :

            제휴희망일 :

            기타문의사항 :
            """
            return message
        }
        
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients(["quiz@cashwalk.io"])
        controller.setSubject("퀴즈 제휴문의")
        controller.setMessageBody(getMailMessage(), isHTML: false)
        self.present(controller, animated: true)
    }
    
    // MARK: - Private selector
    
    @objc private func didClickedContactUsButton() {
        presentBlockUserMailCompose()
    }
    
}

// MARK: - Layout

extension CpqGuideViewController {
    
    private func layout() {
        navigationBarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navigationBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        navigationBarView.bottomAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true
        
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: contactUsButton.bottomAnchor, constant: 21).isActive = true
        
        cpqTitleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20).isActive = true
        cpqTitleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        cpqTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        cpqSubLabel.topAnchor.constraint(equalTo: cpqTitleLabel.bottomAnchor, constant: 8).isActive = true
        cpqSubLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        cpqSubLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        quizPrizeTitleLabel.topAnchor.constraint(equalTo: cpqSubLabel.bottomAnchor, constant: 36).isActive = true
        quizPrizeTitleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        quizPrizeTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        quizPrizeSubLabel.topAnchor.constraint(equalTo: quizPrizeTitleLabel.bottomAnchor, constant: 8).isActive = true
        quizPrizeSubLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        quizPrizeSubLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        precautionsTitleLabel.topAnchor.constraint(equalTo: quizPrizeSubLabel.bottomAnchor, constant: 36).isActive = true
        precautionsTitleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        precautionsTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        precautionsSubLabel.topAnchor.constraint(equalTo: precautionsTitleLabel.bottomAnchor, constant: 8).isActive = true
        precautionsSubLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        precautionsSubLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        horizontalLine.topAnchor.constraint(equalTo: precautionsSubLabel.bottomAnchor, constant: 28).isActive = true
        horizontalLine.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        iconImageView.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor, constant: 30).isActive = true
        iconImageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        iconImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        contactUsTitleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8).isActive = true
        contactUsTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        contactUsTitleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor).isActive = true
        
        contactUsSubLabel.topAnchor.constraint(equalTo: contactUsTitleLabel.bottomAnchor, constant: 8).isActive = true
        contactUsSubLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
        contactUsSubLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        
        contactUsButton.topAnchor.constraint(equalTo: contactUsSubLabel.bottomAnchor, constant: 20).isActive = true
        contactUsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contactUsButton.widthAnchor.constraint(equalToConstant: 176).isActive = true
        contactUsButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
    }
    
}

// MARK: - MFMailComposeViewControllerDelegate

extension CpqGuideViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
// MARK: - MFMessageComposeViewControllerDelegate

extension CpqGuideViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }
}
