//
//  ConsumeHeaderView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 09/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//
import Lottie
import RxSwift
import RxCocoa
import RxGesture
import SnapKit

final class ConsumeHeaderView: CashdocView {
    
    // MARK: - Properties
    
    let selectedTrigger = PublishRelay<String>()
    let cautionButtonTrigger = PublishRelay<String>()
    let addButtonTrigger = PublishRelay<Void>()
    let dimViewTrigger = PublishRelay<Bool>()
    let alertTrigger = PublishRelay<Void>()
    let incomeButtonTrigger = PublishRelay<Void>()
    let outgoingButtonTrigger = PublishRelay<Void>()
    let etcButtonTrigger = PublishRelay<Void>()
    
    private var selectedYear: String!
    private var selectedMonth: String!
    
    private var separator2Leading: Constraint?
    private var incomeCenterX: Constraint?
    private var outgoingCenterX: Constraint?
    
    // MARK: - UI Components
    
    private weak var monthView: UIView!
    private weak var selectMonthButton: UILabel!
    private weak var monthArrowImageView: UIImageView!
    private weak var fakeTextField: UITextField!
    private weak var cautionButton: UIButton!
    private weak var addButton: UIButton!
    private weak var monthPickerView: MonthPickerView!
    private weak var toolBar: UIToolbar!
    private var okButton: UIBarButtonItem!
    private var flexibleSpace: UIBarButtonItem!
    private weak var containerView: UIView!
    private weak var incomeStackView: UIStackView!
    private weak var incomeTitleLabel: UILabel!
    private weak var incomeButton: UIButton!
    private weak var outgoingStackView: UIStackView!
    private weak var outgoingTitleLabel: UILabel!
    private weak var outgoingButton: UIButton!
    private weak var etcStackView: UIStackView!
    private weak var etcTitleLabel: UILabel!
    private weak var etcButton: UIButton!
    private weak var separator2: UIView!
    
    // MARK: - Con(De)structor
    
    override init() {
        super.init()
        bindView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        self.snp.makeConstraints { (m) in
            m.height.equalTo(112)
        }
        monthView = UIView().then {
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview().inset(16)
                m.centerX.equalToSuperview()
            }
        }
        selectMonthButton = UILabel().then {
            $0.setFontToMedium(ofSize: 16)
            $0.textColor = .blackCw
            $0.textAlignment = .center
            monthView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.leading.bottom.equalToSuperview()
            }
        }
        monthArrowImageView = UIImageView().then {
            $0.image = UIImage(named: "icArrow01StyleDownBlack")
            monthView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerY.trailing.equalToSuperview()
                m.leading.equalTo(selectMonthButton.snp.trailing).offset(4)
                m.size.equalTo(12)
            }
        }
        fakeTextField = UITextField().then {
            $0.backgroundColor = .clear
            $0.borderStyle = .none
            $0.tintColor = .clear
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.edges.equalTo(monthView)
            }
        }
        addButton = UIButton().then {
            $0.setImage(UIImage(named: "icPlusBlack"), for: .normal)
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(monthView.snp.top)
                m.trailing.equalToSuperview().inset(16)
                m.size.equalTo(20)
            }
        }
        cautionButton = UIButton().then {
            $0.setImage(UIImage(named: "icCautionColor"), for: .normal)
            $0.isHidden = true
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(monthView.snp.top)
                m.trailing.equalTo(addButton.snp.leading).offset(-16)
                m.size.equalTo(20)
            }
        }
        monthPickerView = MonthPickerView().then {
            $0.backgroundColor = .grayCw
            fakeTextField.inputView = $0
        }
        toolBar = UIToolbar().then {
            $0.barStyle = .default
            $0.isTranslucent = true
            $0.tintColor = .blackCw
            $0.sizeToFit()
            fakeTextField.inputAccessoryView = $0
        }
        okButton = UIBarButtonItem().then {
            $0.title = "확인"
            $0.style = .plain
        }
        flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, okButton], animated: true)
        containerView = UIView().then {
            $0.backgroundColor = .whiteTwoCw
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(monthView.snp.bottom).offset(10)
                m.leading.trailing.equalToSuperview().inset(16)
                m.bottom.equalToSuperview().inset(4)
            }
        }
        etcStackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .fill
            containerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview().inset(9)
                m.bottom.equalToSuperview().inset(8)
                m.trailing.equalToSuperview().inset(16)
            }
        }
        etcTitleLabel = UILabel().then {
            $0.text = "기타"
            $0.setFontToRegular(ofSize: 11)
            $0.textColor = .blackTwoCw
            etcStackView.addArrangedSubview($0)
        }
        etcButton = UIButton().then {
            $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            $0.setTitle("0건", for: .normal)
            $0.setTitleColor(.brownGrayCw, for: .normal)
            etcStackView.addArrangedSubview($0)
        }
        separator2 = UIView().then {
            $0.backgroundColor = .grayCw
            containerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.trailing.equalTo(etcStackView.snp.leading).offset(-16)
                m.centerY.equalToSuperview()
                m.width.equalTo(1)
                m.height.equalTo(26)
            }
        }
        let separator1 = UIView().then {
            $0.backgroundColor = .grayCw
            containerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                separator2Leading = m.leading.equalToSuperview().inset(150).constraint
                m.centerY.equalToSuperview()
                m.width.equalTo(1)
                m.height.equalTo(26)
            }
        }
        incomeStackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .fill
            containerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview().inset(9)
                m.bottom.equalToSuperview().inset(8)
                incomeCenterX = m.centerX.equalTo(containerView.snp.leading).constraint
                m.trailing.lessThanOrEqualTo(separator1.snp.leading).offset(-10)
            }
        }
        incomeTitleLabel = UILabel().then {
            $0.text = "수입"
            $0.setFontToRegular(ofSize: 11)
            $0.textColor = .blackTwoCw
            incomeStackView.addArrangedSubview($0)
        }
        incomeButton = UIButton().then {
            $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            $0.setTitle("0원", for: .normal)
            $0.setTitleColor(.blueCw, for: .normal)
            incomeStackView.addArrangedSubview($0)
        }
        outgoingStackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.distribution = .fill
            containerView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview().inset(9)
                m.bottom.equalToSuperview().inset(8)
                outgoingCenterX = m.centerX.equalTo(separator1.snp.trailing).constraint
                m.trailing.lessThanOrEqualTo(separator2.snp.leading).offset(-10)
            }
        }
        outgoingTitleLabel = UILabel().then {
            $0.text = "지출"
            $0.setFontToRegular(ofSize: 11)
            $0.textColor = .blackTwoCw
            outgoingStackView.addArrangedSubview($0)
        }
        outgoingButton = UIButton().then {
            $0.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
            $0.setTitle("0원", for: .normal)
            $0.setTitleColor(.blackCw, for: .normal)
            outgoingStackView.addArrangedSubview($0)
        }
    }
    
    func setupProperty() {
        self.backgroundColor = .grayTwoCw
        self.selectedYear = String(monthPickerView.years[monthPickerView.selectedRow(inComponent: 0)])
        var month = String(monthPickerView.months[monthPickerView.selectedRow(inComponent: 1)])
        self.selectMonthButton.text = "\(month)월"
        if month.count == 1 {
            month = "0" + String(monthPickerView.months[monthPickerView.selectedRow(inComponent: 1)])
        } else {
            month = String(monthPickerView.months[monthPickerView.selectedRow(inComponent: 1)])
        }
        self.selectedMonth = month
    }
    
    // MARK: - Binding
    
    private func bindView() {
        cautionButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.cautionButtonTrigger.accept(self.selectedYear + self.selectedMonth)
            })
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.addButtonTrigger.accept(())
            }).disposed(by: disposeBag)
        
        monthPickerView.rx.itemSelected
            .subscribe(onNext: { [weak self] (row, component) in
                guard let self = self else { return }
                self.setSelectedYearAndMonth(row, component)
            })
            .disposed(by: disposeBag)
        
        okButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.selectedTrigger.accept(self.selectedYear + self.selectedMonth)
                self.dimViewTrigger.accept(true)
                self.selectMonthButton.text = self.changeDateTitle(year: self.selectedYear, month: self.selectedMonth)
                self.fakeTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        fakeTextField.rx.tapGesture().when(.recognized)
            .bind(onNext: { [weak self] (_) in
                guard let self = self else { return }
                if !SmartAIBManager.shared.consumeLoadingFetching.value {
                    self.monthPickerView.setComponent(year: self.selectedYear, month: self.selectedMonth)
                    self.fakeTextField.becomeFirstResponder()
                    self.dimViewTrigger.accept(false)
                } else {
                    self.alertTrigger.accept(())
                    self.fakeTextField.resignFirstResponder()
                }
            }).disposed(by: disposeBag)
        incomeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.incomeButtonTrigger.accept(())
            })
            .disposed(by: disposeBag)
        
        outgoingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.outgoingButtonTrigger.accept(())
            })
            .disposed(by: disposeBag)
        
        etcButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.etcButtonTrigger.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    func configure(_ item: Int, type: CategoryType) {
        switch type {
        case .수입:
            let incomeString = NSMutableAttributedString.attributedUnderlineText(text: item.commaValue + "원", ofSize: 12, weight: .medium, color: .blueCw, alignment: .right)
            self.incomeButton.setAttributedTitle(incomeString, for: .normal)
        case .지출:
            let outgoingString = NSMutableAttributedString.attributedUnderlineText(text: item.commaValue + "원", ofSize: 12, weight: .medium, color: .blackCw, alignment: .right)
            self.outgoingButton.setAttributedTitle(outgoingString, for: .normal)
        case .기타:
            let etcString = NSMutableAttributedString.attributedUnderlineText(text: String(item) + "건", ofSize: 12, weight: .medium, color: .brownGrayCw, alignment: .right)
            self.etcButton.setAttributedTitle(etcString, for: .normal)
            let widthMultiple: CGFloat = separator2.frame.maxX / 2
            separator2Leading?.update(offset: widthMultiple)
            incomeCenterX?.update(offset: widthMultiple / 2)
            outgoingCenterX?.update(offset: widthMultiple / 2)
        }
    }
    
    func cautionButton(isHidden: Bool) {
        self.cautionButton.isHidden = isHidden
    }
    
    func resignTextField() {
        self.fakeTextField.resignFirstResponder()
    }
    
    func setMonthTitle(date: String) {
        self.selectMonthButton.text = changeDateTitle(date: date)
    }
    
    // MARK: - Private methods
    
    private func setSelectedYearAndMonth(_ row: Int, _ component: Int) {
        switch component {
        case 0:
            self.selectedYear = String(self.monthPickerView.years[row])
        case 1:
            if String(self.monthPickerView.months[row]).count == 1 {
                self.selectedMonth = "0" + String(self.monthPickerView.months[row])
            } else {
                self.selectedMonth = String(self.monthPickerView.months[row])
            }
        default:
            break
        }
    }
    
    private func changeDateTitle(year: String, month: String) -> String {
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "yyyy"
        let currentYear = formatter.string(from: date)
        var month = month
        if month.subString(to: 1) == "0" {
            month = month.subString(from: 1)
        }
        if currentYear == year {
            return month + "월"
        } else {
            return year + "년" + " " + month + "월"
        }
    }
    
    private func changeDateTitle(date: String) -> String {
        let formatter = DateFormatter()
        let currentDate = Date()
        let selectedYear = date.subString(to: 4)
        self.selectedYear = selectedYear
        let selectedMonth = date.subString(from: 4)
        self.selectedMonth = selectedMonth
        formatter.dateFormat = "yyyy"
        let currentYear = formatter.string(from: currentDate)
        var month = selectedMonth
        if month.subString(to: 1) == "0" {
            month = month.subString(from: 1)
        }
        if currentYear == selectedYear {
            return month + "월"
        } else {
            return selectedYear + "년" + " " + month + "월"
        }
    }
}
