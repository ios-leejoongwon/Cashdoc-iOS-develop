//
//  QuizinputAnswerPopupView.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import Then

protocol QuizinputAnswerPopupViewDelegate: NSObjectProtocol {
    func quizinputAnswerPopupViewDidClickedConfirmButton(_ view: QuizinputAnswerPopupView, isCodeRegist: Bool, point: Int?, PointType: Int?)
}

class QuizinputAnswerPopupView: BasePopupView {
    
    // MARK: - Properties
    
    private var backgroudViewCenterY: NSLayoutConstraint?
    private var backgroudViewCenterYConstant: CGFloat?
    weak var delegate: QuizinputAnswerPopupViewDelegate?
    
    var quizID: String!
    var questionId: String!
    
    private var cpqAnswerResult: CpqAnswerPointModel?
    
    // MARK: - UI Components
    
    private let backgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        $0.textColor = .blackTwoCw
        $0.alpha = 0.87
        $0.textAlignment = .center
        $0.text = "정답입력"
    }
    
    private let textField = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = UIColor.blackTwoCw.withAlphaComponent(0.87)
        $0.placeholder = "띄어쓰기 없이 입력해 주세요."
        $0.textAlignment = .left
        $0.doneAccessory = true
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    private let textLineLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(255, 210, 0)
    }
    
    private let warningBackgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.alpha = 0
    }
    
    private let warningRedImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icWarningRed")
    }
    
    private let warningRedLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor.fromRGB(170, 9, 9)
        $0.textAlignment = .left
        $0.text = "정답이 아닙니다. 다시 확인해주세요."
    }
    
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGrayCw
    }
    
    private let verticalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGrayCw
    }
    
    private let cancelButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.blackTwoCw, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .white
    }
    
    private let confirmButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("정답 확인", for: .normal)
        $0.setTitleColor(UIColor.fromRGB(53, 143, 255), for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        $0.backgroundColor = .white
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        setSelector()
        addSubview(backgroundView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(textField)
        backgroundView.addSubview(textLineLabel)
        backgroundView.addSubview(horizontalLine)
        backgroundView.addSubview(verticalLine)
        backgroundView.addSubview(cancelButton)
        backgroundView.addSubview(confirmButton)
        backgroundView.addSubview(warningBackgroundView)
        warningBackgroundView.addSubview(warningRedImageView)
        warningBackgroundView.addSubview(warningRedLabel)
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        print("[👋deinit2]\(String(describing: self))")
    }
    
    // MARK: - Overridden: BasePopupView
    
    override var isDismissEnabledBackgroundTouch: Bool {
        return false
    }

    // MARK: - Private methods
    
    private func requestPostAnswer() {
        guard let answer = textField.text else {return}
        #if CASHWALK
        let deviceID = AppGlobalFunc.getUUIdFromKeyChain()
        #else
        let deviceID = GlobalFunction.getDeviceID()
        #endif
        
        CpqManager.shared.postAnswer(quizId: quizID, questionId: questionId, answer: answer, deviceId: deviceID) { (error, result) in
            guard error == nil else {
                if error?.code == 100 {
                    let toastText = "네크워크 상태가 불안정합니다. 잠시후 다시 시도해주세요."
                    self.makeToast(toastText, position: .bottom)
                    // self.confirmButton.isUserInteractionEnabled = true
                } else if error?.code == 132 {
                    // 오답
                    self.delegate?.quizinputAnswerPopupViewDidClickedConfirmButton(self, isCodeRegist: true, point: 0, PointType: 0)
                    // self.confirmButton.isUserInteractionEnabled = true
                }
                return
            }
            self.cpqAnswerResult = result
            let point = self.cpqAnswerResult?.point
            let pointType = self.cpqAnswerResult?.pointType 
            GlobalFunction.SendBrEvent(name: "earning cash - quiz", properti: ["cash_earned": point ?? 0, "content_id": self.questionId ?? "", "content_name": "quiz"])
            self.delegate?.quizinputAnswerPopupViewDidClickedConfirmButton(self, isCodeRegist: true, point: point, PointType: pointType)
            // 정답입력완료 후 정답 팝업창 띄우기
            self.dismissView()
            
        }
        
    }
    
    private func setProperties() {
        containerView.backgroundColor = .clear
        textField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(showWillKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideWillKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setSelector() {
        cancelButton.addTarget(self, action: #selector(didClickedCancelButton), for: .touchUpInside)
        // confirmButton.addTarget(self, action: #selector(didClickedConfirmButton), for: .touchUpInside)
        confirmButton.rx.tapGesture().when(.recognized)
            .throttle(.seconds(2), latest: false, scheduler: MainScheduler.asyncInstance)
            .bind { [weak self] _ in
                self?.didClickedConfirmButton()
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Private selector
    
    @objc private func didClickedCancelButton() {
        dismissView()
    }
    
    @objc private func didClickedConfirmButton() {
        textField.resignFirstResponder()
        
        #if CASHWALK
        let isConnected = AppGlobalFunc.isConnectedToNetwork()
        #else
        let isConnected = ReachabilityManager.reachability.connection != .unavailable
        #endif
        
        if isConnected {
            // confirmButton.isUserInteractionEnabled = false
            requestPostAnswer()
        } else {
            self.delegate?.quizinputAnswerPopupViewDidClickedConfirmButton(self, isCodeRegist: false, point: 0, PointType: 0)
            self.dismissView()
        }
    }
    
    @objc private func showWillKeyboard(_ notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_6 {
            backgroudViewCenterYConstant = backgroudViewCenterY?.constant
            UIView.animate(withDuration: TimeInterval(truncating: duration)) {
                self.backgroudViewCenterY?.constant = -100
                self.layoutIfNeeded()
            }
        }
    }
    
    @objc private func hideWillKeyboard(_ notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_6 {
            UIView.animate(withDuration: TimeInterval(truncating: duration)) {
                self.backgroudViewCenterY?.constant = self.backgroudViewCenterYConstant ?? 0
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Internal methods
    func warningBackgroundViewAnimation() {
        warningBackgroundView.alpha = 1
        textLineLabel.backgroundColor = UIColor.fromRGB(255, 65, 65)
        
        let animation = CASpringAnimation(keyPath: "position.x")
        
        animation.fromValue = 2 + warningBackgroundView.frame.midX
        let toValue = 0 + warningBackgroundView.frame.midX
        animation.toValue = toValue
        
        animation.damping = 5
        animation.mass = 1
        animation.stiffness = 5000
        animation.initialVelocity = 100
        
        animation.beginTime = CACurrentMediaTime() + 0
        animation.duration = animation.settlingDuration
        
        CATransaction.setCompletionBlock({
            self.warningBackgroundView.layer.position.x = toValue
        })
        warningBackgroundView.layer.add(animation, forKey: nil)
        CATransaction.commit()
        
    }
}

// MARK: - Layout

extension QuizinputAnswerPopupView {
    
    private func layout() {
        
        backgroundView.widthAnchor.constraint(equalToConstant: 288).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 192).isActive = true
        backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        backgroudViewCenterY = backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor)
        backgroudViewCenterY?.isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 24).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16).isActive = true
        
        textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24).isActive = true
        textField.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 32).isActive = true
        textField.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -32).isActive = true
        
        textLineLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 9).isActive = true
        textLineLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16).isActive = true
        textLineLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16).isActive = true
        textLineLabel.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        warningBackgroundView.topAnchor.constraint(equalTo: textLineLabel.bottomAnchor, constant: 8).isActive = true
        warningBackgroundView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16).isActive = true
        warningBackgroundView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16).isActive = true
        warningBackgroundView.heightAnchor.constraint(equalToConstant: 17).isActive = true
        
        warningRedImageView.centerYAnchor.constraint(equalTo: warningBackgroundView.centerYAnchor).isActive = true
        warningRedImageView.leadingAnchor.constraint(equalTo: warningBackgroundView.leadingAnchor).isActive = true
        warningRedImageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
        warningRedImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        
        warningRedLabel.centerYAnchor.constraint(equalTo: warningBackgroundView.centerYAnchor).isActive = true
        warningRedLabel.leadingAnchor.constraint(equalTo: warningRedImageView.trailingAnchor, constant: 4).isActive = true
        warningRedLabel.trailingAnchor.constraint(equalTo: warningBackgroundView.trailingAnchor).isActive = true
        
        horizontalLine.topAnchor.constraint(equalTo: textLineLabel.bottomAnchor, constant: 41).isActive = true
        horizontalLine.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        verticalLine.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        verticalLine.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor).isActive = true
        verticalLine.trailingAnchor.constraint(equalTo: confirmButton.leadingAnchor).isActive = true
        verticalLine.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true
        verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        cancelButton.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        cancelButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 143.5).isActive = true
        
        confirmButton.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        confirmButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        confirmButton.widthAnchor.constraint(equalToConstant: 143.5).isActive = true
        
        backgroundView.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor).isActive = true
        
    }
}

extension QuizinputAnswerPopupView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        requestPostAnswer()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string != " " else { return false }
        guard let text = textField.text else { return true }
        let count = text.count + string.count - range.length
        
        return count < 20
    }
}
