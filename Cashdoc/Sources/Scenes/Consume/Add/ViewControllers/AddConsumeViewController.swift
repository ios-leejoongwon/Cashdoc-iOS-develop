//
//  AddConsumeViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 19/12/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import SwiftyJSON

final class AddConsumeViewController: CashdocViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeViewHeight: NSLayoutConstraint!
    @IBOutlet var consumeTypeButton: [UIButton]!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var originalPriceTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var originalPriceLabel: UILabel!
    @IBOutlet weak var expedientLabel: UILabel!
    @IBOutlet weak var expedientTextField: UITextField!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var memoTextField: UITextField!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var betweenButtonsConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var item: ConsumeContentsItem?
    var viewModel: AddConsumeViewModel!
    private var categoryType: CollectionActionSheetType!
    private var category = String()
    private var selectedYear = String(Calendar.current.component(.year, from: Date()))
    private var selectedMonth = String(Calendar.current.component(.month, from: Date()))
    private var selectedDay = String(Calendar.current.component(.day, from: Date()))
    private var selectedHour = String(Calendar.current.component(.hour, from: Date()))
    private var selectedMinute = String(Calendar.current.component(.minute, from: Date()))
    private var selectedDate = String()
    private var selectedTime = String()
    
    private let dimView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blackCw
        $0.alpha = 0.5
        $0.isHidden = true
    }
    private let yearToDatePickerView = YearToDatePickerView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    private let toolBar = UIToolbar().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.barStyle = .default
        $0.backgroundColor = .white
        $0.isTranslucent = true
        $0.tintColor = .blackCw
        $0.sizeToFit()
    }
    private let okButton = UIBarButtonItem().then {
        $0.title = "확인"
        $0.style = .plain
    }
    private let flexibleSpace: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        return button
    }()
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindView()
        setProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    private func setProperties() {
        // item이 존재한다는 건 수정하는 경우
        if let item = item {
            fillItemProperties(item)
        } else {
            title = "지출 추가"
            category = "지출"
            categoryType = .지출
            setTitleWithoutAnimation(button: categoryButton, title: "미분류")
            categoryImageView.image = UIImage(named: viewModel.categoryImageName(with: (self.category, "미분류")))
            consumeTypeButton.first?.layer.borderColor = UIColor.blackCw.cgColor
            removeOriginalPriceUI()
        }
        hideKeyboardWhenTappedAround()
        contentTextField.delegate = self
        priceTextField.delegate = self
        memoTextField.delegate = self
        expedientTextField.delegate = self
        timeTextField.inputView = yearToDatePickerView
        timeTextField.inputAccessoryView = toolBar
        toolBar.setItems([flexibleSpace, okButton], animated: true)
        setButton()
        setNotification()
        setLayout()
    }
    
    // MARK: - Bind
    
    private func bindView() {
        timeTextField.rx.tapGesture()
        .skip(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.dimView.isHidden = false
            })
        .disposed(by: disposeBag)

        dimView.rx.tapGesture()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.timeTextField.resignFirstResponder()
                self.dimView.isHidden = true
                self.saveButton.isEnabled = self.isEnableButton()
            })
        .disposed(by: disposeBag)

        if let item = item {
            removeButton.rx.tap
            .map { item }
            .bind(onNext: { [weak self] item in
                guard let self = self else { return }
                UIAlertController.presentAlertController(target: self, title: "삭제", massage: "선택하신 내역이 삭제됩니다.\n정말 삭제하시겠습니까?", okBtnTitle: "예", cancelBtn: true, cancelBtnTitle: "아니요") { (_) in
                    self.viewModel.removeItemFromRealm(item)
                }
            })
            .disposed(by: disposeBag)
        }
        
        okButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.timeTextField.resignFirstResponder()
                self.dimView.isHidden = true
                self.timeTextField.text = self.convertFullDate(year: self.selectedYear, month: self.selectedMonth, day: self.selectedDay, hour: self.selectedHour, minute: self.selectedMinute)
                self.saveButton.isEnabled = self.isEnableButton()
            })
        .disposed(by: disposeBag)
        
        yearToDatePickerView.rx.itemSelected
            .subscribe(onNext: { [weak self] (index, component) in
                guard let self = self else { return }
                switch component {
                case 0:
                    self.selectedYear = String(index + 1900)
                case 1:
                    if index < 9 {
                        self.selectedMonth = "0" + String(index + 1)
                    } else {
                        self.selectedMonth = String(index + 1)
                    }
                case 2:
                    if index < 9 {
                        self.selectedDay = "0" + String(index + 1)
                    } else {
                        self.selectedDay = String(index + 1)
                    }
                case 3:
                    if index < 9 {
                        self.selectedHour = "0" + String(index)
                    } else {
                        self.selectedHour = String(index)
                    }
                case 4:
                    if index < 9 {
                        self.selectedMinute = "0" + String(index)
                    } else {
                        self.selectedMinute = String(index)
                    }
                default:
                    break
                }
                self.timeTextField.text = self.convertFullDate(year: self.selectedYear, month: self.selectedMonth, day: self.selectedDay, hour: self.selectedHour, minute: self.selectedMinute)
                self.saveButton.isEnabled = self.isEnableButton()
            })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private Methods
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setButton() {
        self.saveButton.setTitleColor(.blackCw, for: .normal)
        self.saveButton.setBackgroundColor(.yellowCw, forState: .normal)
        self.saveButton.setTitleColor(.veryLightPinkCw, for: .disabled)
        self.saveButton.setBackgroundColor(.whiteCw, forState: .disabled)
        self.saveButton.clipsToBounds = true
        self.saveButton.layer.cornerRadius = 4
        self.saveButton.isEnabled = isEnableButton()
    }
    
    private func isEnableButton() -> Bool {
        if self.categoryImageView.image == nil {
            return false
        }
        if self.contentTextField.text == "" {
            return false
        }
        if self.priceTextField.text == "0" || self.priceTextField.text == "" {
            return false
        }
        if expedientTextField.text == "" {
            return false
        }
        if timeTextField.text == "" {
            return false
        }
        
        return true
    }
    
    private func removeOriginalPriceUI() {
        // 인식 금액 및 안내 뷰 삭제
        self.originalPriceLabel.text = nil
        self.originalPriceTopConstraint.constant = 0
        self.noticeViewHeight.constant = 0
        self.view.setNeedsLayout()
    }
    
    private func setTitleLabel(_ type: String) {
        if item == nil {
            self.title = "\(type) 추가"
        } else {
            self.title = "\(type) 상세내역 수정"
        }
        self.category = type
        for button in consumeTypeButton {
            if button.titleLabel?.text == type {
                button.layer.borderColor = UIColor.blackCw.cgColor
            } else {
                button.layer.borderColor = UIColor.grayCw.cgColor
            }
        }
        switch type {
        case "지출":
            self.setTitleWithoutAnimation(button: self.categoryButton, title: "미분류")
            self.categoryImageView.image = UIImage(named: viewModel.categoryImageName(with: (self.category, "미분류")))
            self.categoryType = .지출
            self.contentTitleLabel.text = "결제내용"
            self.contentTextField.placeholder = "결제내용을 입력해 주세요."
            self.expedientLabel.text = "결제수단"
            self.expedientTextField.placeholder = "결제수단을 입력해 주세요."
            self.timeLabel.text = "결제일시"
        case "수입":
            self.setTitleWithoutAnimation(button: self.categoryButton, title: "미분류")
            self.categoryImageView.image = UIImage(named: viewModel.categoryImageName(with: (self.category, "미분류")))
            self.categoryType = .수입
            self.contentTitleLabel.text = "입금내용"
            self.contentTextField.placeholder = "입금내용을 입력해 주세요."
            self.expedientLabel.text = "입금수단"
            self.expedientTextField.placeholder = "입금수단을 입력해 주세요."
            self.timeLabel.text = "입금일시"
        case "기타":
            self.setTitleWithoutAnimation(button: self.categoryButton, title: "카드대금")
            self.categoryImageView.image = UIImage(named: viewModel.categoryImageName(with: (self.category, "카드대금")))
            self.categoryType = .기타
            self.contentTitleLabel.text = "내용"
            self.contentTextField.placeholder = "내용을 입력해 주세요."
            self.expedientLabel.text = "수단"
            self.expedientTextField.placeholder = "수단을 선택해 주세요."
            self.timeLabel.text = "일시"
        default:
            break
        }
    }
    
    private func convertFullDate(year: String, month: String, day: String, hour: String, minute: String) -> String {
        self.selectedYear = year
        let month = viewModel.makeTwoLength(strNum: month)
        let day = viewModel.makeTwoLength(strNum: day)
        let hour = viewModel.makeTwoLength(strNum: hour)
        let minute = viewModel.makeTwoLength(strNum: minute)
        self.selectedDate = self.selectedYear + month + day
        self.selectedTime = hour + minute + "00"
        return "\(year).\(month).\(day) \(hour):\(minute)"
    }
    
    private func setLayout() {
        if self.item == nil {
            buttonsWidthConstraint.isActive = false
            removeButton.widthAnchor.constraint(equalToConstant: 0).isActive = true
            betweenButtonsConstraint.constant = 0
            betweenButtonsConstraint.isActive = true
            
        } else {

            betweenButtonsConstraint.constant = 8
            betweenButtonsConstraint.isActive = true
        }
    }
    
    private func fillItemProperties(_ item: ConsumeContentsItem) {
        self.setTitleLabel(item.category)
        for button in consumeTypeButton {
            if button.titleLabel?.text == item.category {
                button.layer.borderColor = UIColor.blackCw.cgColor
            } else {
                button.layer.borderColor = UIColor.grayCw.cgColor
            }
        }
        switch item.category {
        case "지출":
            self.title = "지출 상세내역 수정"
            self.categoryType = .지출
            self.priceTextField.text = item.outgoing.commaValue + "원"
            self.originalPriceLabel.text = "(인식금액: \(item.originalPrice.commaValue + "원"))"
        case "수입":
            self.title = "수입 상세내역 수정"
            self.categoryType = .수입
            self.priceTextField.text = item.income.commaValue + "원"
            self.originalPriceLabel.text = "(인식금액: \(item.originalPrice.commaValue + "원"))"
        case "기타":
            self.title = "기타 상세내역 수정"
            self.categoryType = .기타
            if item.outgoing == 0 {
                self.priceTextField.text = item.income.commaValue + "원"
            } else {
                self.priceTextField.text = item.outgoing.commaValue + "원"
            }
            self.originalPriceLabel.text = "(인식금액: \(item.originalPrice.commaValue + "원"))"
        default:
            break
        }
        if item.consumeType == "수기" {
            removeOriginalPriceUI()
        }
        
        self.categoryImageView.image = UIImage(named: viewModel.categoryImageName(with: (item.category, item.subCategory)))
        self.setTitleWithoutAnimation(button: self.categoryButton, title: item.subCategory)
        
        consumeTypeButton.forEach { (button) in
            if item.category == button.titleLabel?.text {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
        contentTextField.text = item.title
        expedientTextField.text = item.subTitle
        
        self.noticeViewHeight.constant = 50
        self.selectedDate = item.date
        self.selectedTime = item.time
        timeTextField.text = convertToTimeText(date: item.date, time: item.time)
        
        if item.memo != "" {
            memoTextField.text = item.memo
        }
    }
    
    private func convertToTimeText(date: String, time: String) -> String {
        var dateStr = String()
        var timeStr = String()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        if let dateData = formatter.date(from: date) {
            formatter.dateFormat = "yyyy.MM.dd"
            dateStr = formatter.string(from: dateData)
        } else {
            formatter.dateFormat = "yyyy.MM.dd"
            dateStr = formatter.string(from: Date())
        }
        
        formatter.dateFormat = "HHmmss"
        if let timeData = formatter.date(from: time) {
            formatter.dateFormat = "HH:mm"
            timeStr = formatter.string(from: timeData)
        } else {
            formatter.dateFormat = "HH:mm"
            timeStr = formatter.string(from: Date())
        }
        return dateStr + " " + timeStr
    }
    
    private func makeJSON(_ type: CollectionActionSheetType) -> JSON {
        var json = JSON()
        let price = self.priceTextField.text?.replace(target: "원", withString: "").replace(target: ",", withString: "")
        switch self.categoryType {
        case .수입:
            json = JSON(["category": self.category,
                         "subCategory": self.categoryButton.titleLabel?.text as Any,
                         "contents": self.contentTextField.text as Any,
                         "expedient": self.expedientTextField.text as Any,
                         "income": price as Any,
                         "outgoing": "0",
                         "isTouchEnabled": true,
                         "isDeleted": false,
                         "touchCount": 0,
                         "date": self.selectedDate,
                         "time": self.selectedTime,
                         "memo": self.memoTextField.text ?? "",
                         "gb": "입금"
            ])
        default:
            json = JSON(["category": self.category,
                         "subCategory": self.categoryButton.titleLabel?.text as Any,
                         "contents": self.contentTextField.text as Any,
                         "expedient": self.expedientTextField.text as Any,
                         "income": "0",
                         "outgoing": price as Any,
                         "isTouchEnabled": true,
                         "isDeleted": false,
                         "touchCount": 0,
                         "date": self.selectedDate,
                         "time": self.selectedTime,
                         "memo": self.memoTextField.text ?? "",
                         "gb": "출금"
            ])
        }
        return json
    }
    
    private func isRepaired() -> Bool {
        guard let item = self.item else { return true }
        guard let content = self.contentTextField.text,
            let subCategory = self.categoryButton.titleLabel?.text,
            let expedient = self.expedientTextField.text,
            let price = self.priceTextField.text?.replace(target: "원", withString: "").replace(target: ",", withString: "") else { return false }
        if item.title == content &&
            item.category == self.category &&
            item.subTitle == expedient &&
            item.subCategory == subCategory &&
            (item.income == price.toInt || item.outgoing == price.toInt) &&
            item.date == self.selectedDate &&
            item.time == self.selectedTime {
            return false
        }
        return true
    }
    
    private func isRepairedMemo() -> Bool {
        guard let item = self.item else { return true }
        guard let memo = self.memoTextField.text else { return true }
        if item.memo == memo {
            return false
        }
        return true
    }
    
    private func setTitleWithoutAnimation(button: UIButton, title: String) {
        UIView.performWithoutAnimation {
            button.setTitle(title, for: .normal)
            button.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        scrollView.contentInset = .zero
    }
    
    // MARK: - IBAction
    
    @IBAction func consumeTypeBtnAction(_ sender: UIButton) {
        consumeTypeButton.forEach { (button) in
            if button.tag == sender.tag {
                button.isSelected = true
                if let title = button.currentTitle {
                    setTitleLabel(title)
                }
            } else {
                button.isSelected = false
            }
        }
    }
    
    @IBAction func categoryBtnAction(_ sender: UIButton) {
        let sections = viewModel.setCollectionActionSheetSection(type: self.categoryType)
        GlobalFunction.CDCollectionActionSheet(self.categoryType, sections: sections) { [weak self] item in
            guard let self = self else { return }
            switch item {
            case .category(let category):
                self.categoryImageView.image = UIImage(named: self.viewModel.categoryImageName(with: (category.categoryTitle, category.categoryName)))
                self.setTitleWithoutAnimation(button: self.categoryButton, title: category.categoryName)
            default:
                break
            }
        }
    }
    
//    @IBAction func expedientBtnAction(_ sender: UIButton) {
//        guard let title = self.expedientLabel.text else { return }
//        
//        viewModel.presentActionSheet(title) { [weak self] (item) in
//            guard let self = self else { return }
//            self.setTitleWithoutAnimation(button: self.expedientButton, title: item)
//            self.expedientButton.setTitleColor(.blackCw, for: .normal)
//            self.saveButton.isEnabled = self.isEnableButton()
//        }
//    }
    
    @IBAction func saveBtnAction(_ sender: UIButton) {
        let json = makeJSON(self.categoryType)
        GlobalFunction.FirLog(string: "가계부_수기입력_\(self.categoryType.rawValue)_저장_클릭")
        if let item = item {
            if AccountTransactionRealmProxy().containsFromId(item.identity) {
                AccountTransactionRealmProxy().updateTransactionDetailList(id: item.identity, json: json)
            } else if CardApprovalRealmProxy().containsFromId(item.approvalNum) {
                CardApprovalRealmProxy().updateCardDetailList(id: item.identity, json: json)
            } else if ManualConsumeRealmProxy().containsFromId(item.identity) {
                ManualConsumeRealmProxy().updateManualConsumeList(id: item.identity, json: json)
            }
            viewModel.popToVCWithSaving()
        } else {
            ManualConsumeRealmProxy().append(ManualConsumeList(json: json))
            viewModel.popToRootVCWithSaving(self.category)
        }
    }
}

extension AddConsumeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.memoTextField || textField == self.expedientTextField {
            let newLength = (textField.text?.count ?? 0) + string.count - range.length
            return !(newLength > 30)
        } else if textField == self.contentTextField {
            let newLength = (textField.text?.count ?? 0) + string.count - range.length
            if newLength == 0 {
                textField.text = ""
            }
            self.saveButton.isEnabled = isEnableButton()
            return !(newLength > 15)
        } else {
            guard let char  = string.cString(using: String.Encoding.utf8), var text = textField.text?.replace(target: ",", withString: "") else { return false }
            text = text.replace(target: "원", withString: "")
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                if text.count == 1 {
                    textField.text = nil
                    self.saveButton.isEnabled = isEnableButton()
                    return false
                } else {
                    text.removeLast()
                }
            } else {
                text += string
            }
            textField.text = text.commaValue + "원"
            self.saveButton.isEnabled = isEnableButton()
            return false
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
