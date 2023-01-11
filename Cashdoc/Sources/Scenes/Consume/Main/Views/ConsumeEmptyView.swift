//
//  ConsumeEmptyView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 12/03/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class ConsumeEmptyView: UIView {
    
    // MARK: - Properties
    
    private var selectedYear: String = "2020년"
    private var selectedMonth: String = "1월"
    
    let disposeBag = DisposeBag()
    let selectedTrigger = PublishRelay<String>()
    let cautionButtonTrigger = PublishRelay<String>()
    let addButtonTrigger = PublishRelay<Void>()
    let dimViewTrigger = PublishRelay<Bool>()
    let alertTrigger = PublishRelay<Void>()
    
    // MARK: - UI Components
    
    private weak var monthPickerView: MonthPickerView!
    private weak var selectMonthButton: UIButton!
    private weak var fakeTextField: UITextField!
    private weak var fakeButton: UIButton!
    private weak var cautionButton: UIButton!
    private weak var addButton: UIButton!
    private var okButton: UIBarButtonItem!
    
    private weak var tipLink: UIButton!
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        bindView()
        setProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setupView() {
        self.backgroundColor = .grayTwoCw
        
        let topView = UIView().then {
            $0.clipsToBounds = true
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.leading.trailing.equalToSuperview()
                m.height.equalTo(60)
            }
        }
        let monthView = UIView().then {
            $0.clipsToBounds = true
            topView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.center.equalToSuperview()
                m.height.equalTo(24)
            }
        }
        selectMonthButton = UIButton().then {
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            $0.setTitleColor(.blackCw, for: .normal)
            monthView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.bottom.leading.equalToSuperview()
            }
        }
        let selectMonthImageView = UIImageView().then {
            $0.image = UIImage(named: "icArrow01StyleDownBlack")
            monthView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerY.equalTo(selectMonthButton)
                m.leading.equalTo(selectMonthButton.snp.trailing)
                m.trailing.equalToSuperview()
                m.size.equalTo(12)
            }
        }
        fakeTextField = UITextField().then {
            $0.backgroundColor = .clear
            $0.borderStyle = .none
            $0.tintColor = .clear
            topView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.bottom.leading.equalTo(selectMonthButton)
                m.trailing.equalTo(selectMonthImageView)
            }
        }
        fakeButton = UIButton().then {
            $0.backgroundColor = .clear
            topView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.bottom.leading.equalTo(selectMonthButton)
                m.trailing.equalTo(selectMonthImageView)
            }
        }
        addButton = UIButton().then {
            $0.setImage(UIImage(named: "icPlusBlack"), for: .normal)
            topView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.trailing.equalToSuperview().inset(16)
                m.size.equalTo(20)
            }
        }
        cautionButton = UIButton().then {
            $0.setImage(UIImage(named: "icCautionColor"), for: .normal)
            $0.isHidden = true
            topView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerY.equalToSuperview()
                m.trailing.equalTo(addButton.snp.leading).offset(-16)
                m.size.equalTo(20)
            }
        }
        monthPickerView = MonthPickerView().then {
            $0.backgroundColor = .grayCw
            fakeTextField.inputView = $0
        }
        let toolBar = UIToolbar().then {
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
        let flexibleSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, okButton], animated: true)
        
        let titleLabel = UILabel().then {
            $0.setFontToBold(ofSize: 16)
            $0.setLineHeight(lineHeight: 24)
            $0.textColor = .blackCw
            $0.textAlignment = .center
            $0.text = "이번달 수입,지출 내역이 없네요."
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.centerY.equalToSuperview().inset(17)
            }
        }
        _ = UIImageView().then {
            $0.image = UIImage(named: "imgExpenseNone2")
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.bottom.equalTo(titleLabel.snp.top).offset(-16)
                m.size.equalTo(80)
            }
        }
        let descLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.setLineHeight(lineHeight: 22)
            $0.textColor = .brownishGrayCw
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.text = "소비내역 직접 입력해서\n가계부를 이용하세요."
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(titleLabel.snp.bottom).offset(8)
                m.centerX.equalToSuperview()
            }
        }
        tipLink = UIButton().then {
            $0.setTitle("가계부 관리하는 방법", for: .normal)
            $0.setTitleColor(.blackCw, for: .normal)
            $0.setTitleUnderLine("가계부 관리하는 방법")
            $0.titleLabel?.font = .systemFont(ofSize: 14)
            addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.top.equalTo(descLabel.snp.bottom).offset(40)
            }
        }
    }
    
    func cautionButton(isHidden: Bool) {
        self.cautionButton.isHidden = isHidden
    }
    
    private func setProperties() {
        self.selectedYear = String(monthPickerView.years[monthPickerView.selectedRow(inComponent: 0)])
        var month = String(monthPickerView.months[monthPickerView.selectedRow(inComponent: 1)])
        self.selectMonthButton.setTitle("\(month)월", for: .normal)
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
                self.selectMonthButton.setTitle(self.changeDateTitle(year: self.selectedYear, month: self.selectedMonth), for: .normal)
                self.fakeTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        self.fakeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if !SmartAIBManager.shared.consumeLoadingFetching.value {
                    self.monthPickerView.setComponent(year: self.selectedYear, month: self.selectedMonth)
                    self.fakeTextField.becomeFirstResponder()
                    self.dimViewTrigger.accept(false)
                } else {
                    self.alertTrigger.accept(())
                    self.fakeTextField.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        tipLink.rx.tap.bind { (_) in 
            GlobalFunction.pushToWebViewController(title: "가계부 관리하는 방법", url: API.CONSUME_HOWTO_URL, webType: .terms)
        }.disposed(by: disposeBag)
    }
    
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
    
    func setMonthTitle(date: String) {
        self.selectMonthButton.setTitle(changeDateTitle(date: date), for: .normal)
    }
}
