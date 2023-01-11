//
//  DetailConsumeViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 06/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class DetailConsumeViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var item: ConsumeContentsItem!
    private var viewModel: DetailConsumeViewModel!
    private var repairButton: UIButton!
    private var removeButton: UIButton!
    
    // MARK: - UI Components
    
    private let consumeMainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    private let consumeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icMealBlack")
        return imageView
    }()
    private let consumeTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToMedium(ofSize: 14)
        label.textColor = .blackCw
        return label
    }()
    private let consumeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToMedium(ofSize: 24)
        label.textColor = .blackCw
        return label
    }()
    private let consumeDetailView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    private let payMethodTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.textColor = .brownishGrayCw
        label.text = "결제수단"
        return label
    }()
    private let payMethodLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.textColor = .blackCw
        label.numberOfLines = 2
        return label
    }()
    private let payContentTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.textColor = .brownishGrayCw
        label.text = "결제내용"
        return label
    }()
    private let payContentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.textColor = .blackCw
        label.numberOfLines = 2
        return label
    }()
    private let payDateTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.textColor = .brownishGrayCw
        label.text = "결제일시"
        return label
    }()
    private let payDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.textColor = .blackCw
        return label
    }()
    private let memoTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.textColor = .brownishGrayCw
        label.text = "메모"
        return label
    }()
    private let memoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.text = "없음"
        return label
    }()
    private let bottomWhiteView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    // MARK: - Overridden: UIViewController
    init(viewModel: DetailConsumeViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(consumeMainView)
        consumeMainView.addSubview(consumeImageView)
        consumeMainView.addSubview(consumeTitleLabel)
        consumeMainView.addSubview(consumeLabel)
        
        view.addSubview(consumeDetailView)
        consumeDetailView.addSubview(payMethodTitleLabel)
        consumeDetailView.addSubview(payMethodLabel)
        consumeDetailView.addSubview(payContentTitleLabel)
        consumeDetailView.addSubview(payContentLabel)
        consumeDetailView.addSubview(payDateTitleLabel)
        consumeDetailView.addSubview(payDateLabel)
        consumeDetailView.addSubview(memoTitleLabel)
        consumeDetailView.addSubview(memoLabel)
        view.addSubview(bottomWhiteView)
        initComponents()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setPropertiesUsingConsumeItem(itme: item)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .grayTwoCw
        switch item.category {
        case "지출":
            self.consumeLabel.text = item.outgoing.commaValue + "원"
            if let getImage = UIImage(named: CategoryConverter.지출(CategoryOutgoings(rawValue: item.subCategory) ?? .미분류).image) {
                self.consumeImageView.image = getImage
            }
            self.payMethodTitleLabel.text = "결제수단"
            self.payContentTitleLabel.text = "결제내용"
            self.payDateTitleLabel.text = "결제일시"
            self.title = "지출 상세 내역"
        case "수입":
            self.consumeLabel.text = item.income.commaValue + "원"
            if let getImage = UIImage(named: CategoryConverter.수입(CategoryIncomes(rawValue: item.subCategory) ?? .미분류).image) {
                self.consumeImageView.image = getImage
            }
            self.payMethodTitleLabel.text = "입금수단"
            self.payContentTitleLabel.text = "입금내용"
            self.payDateTitleLabel.text = "입금일시"
            self.title = "수입 상세 내역"
        case "기타":
            if item.outgoing == 0 {
                self.consumeLabel.text = item.income.commaValue + "원"
            } else {
                self.consumeLabel.text = item.outgoing.commaValue + "원"
            }
            if let getImage = UIImage(named: CategoryConverter.기타(CategoryEtc(rawValue: item.subCategory) ?? .미분류).image) {
                self.consumeImageView.image = getImage
            }
            self.payMethodTitleLabel.text = "수단"
            self.payContentTitleLabel.text = "내용"
            self.payDateTitleLabel.text = "일시"
            self.title = "기타 상세 내역"
        default:
            break
        }
        
        if item.cardApprovalGuBun.contains("취소") {
            self.consumeLabel.attributedText = (self.consumeLabel.text ?? "").strikeThrough()
        }
        
        self.consumeTitleLabel.text = item.subCategory
        self.payMethodLabel.text = item.subTitle
        self.payDateLabel.text = convertDate(date: item.date, time: item.time)
        self.payContentLabel.text = item.title
        if item.title == "" {
            self.payContentLabel.text = "-"
        }

        setMemoText(memo: item.memo)
    }
    
    private func setMemoText(memo: String?) {
        if let memo = memo, memo != "" {
            self.memoLabel.text = memo
        } else {
            self.memoLabel.text = "없음"
        }
    }
    
    private func initComponents() {
        repairButton = UIButton().then {
            $0.backgroundColor = .white
            $0.setTitle("편집", for: .normal)
            $0.setTitleColor(.brownishGrayCw, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.titleLabel?.textAlignment = .center
            $0.layer.cornerRadius = 4
            $0.layer.borderColor = UIColor.grayCw.cgColor
            $0.layer.borderWidth = 1
            $0.addTarget(self, action: #selector(repairBtnAction), for: .touchUpInside)
            self.consumeDetailView.addSubview($0)
            $0.snp.makeConstraints {
                $0.left.equalToSuperview().offset(16)
                $0.bottom.equalToSuperview().offset(-16)
                $0.height.equalTo(48)
            }
        }
        
        removeButton = UIButton().then {
            $0.backgroundColor = .white
            $0.setTitle("삭제", for: .normal)
            $0.setTitleColor(.redCw, for: .normal)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.titleLabel?.textAlignment = .center
            $0.layer.cornerRadius = 4
            $0.layer.borderColor = UIColor.redCw.cgColor
            $0.layer.borderWidth = 1
            $0.addTarget(self, action: #selector(removeBtnAction), for: .touchUpInside)
            self.consumeDetailView.addSubview($0)
            $0.snp.makeConstraints {
                $0.right.equalToSuperview().offset(-16)
                $0.bottom.equalToSuperview().offset(-16)
                $0.height.equalTo(48)
                $0.left.equalTo(repairButton.snp.right).offset(7)
                $0.width.equalTo(repairButton)
            }
        }
    }
    
    private func setPropertiesUsingConsumeItem(itme: ConsumeContentsItem) {
        if let transaction = AccountTransactionRealmProxy().transactionFromIdentity(item.identity) {
            item.category = transaction.category
            item.subCategory = transaction.subCategory
            item.income = transaction.inBal
            item.outgoing = transaction.outBal
            item.subTitle = transaction.expedient
            item.title = transaction.jukyo
            item.date = transaction.tranDate.simpleDateFormat("yyyyMMdd")
            item.time = transaction.tranDt
            item.memo = transaction.memo
        } else if let transaction = CardApprovalRealmProxy().ApprovalFromAppNumber(item.identity) {
            item.category = transaction.category
            item.subCategory = transaction.subCategory
            if item.category == "수입" {
                item.income = transaction.appAmt
                item.outgoing = 0
            } else {
                item.income = 0
                item.outgoing = transaction.appAmt
            }
            item.subTitle = transaction.appNickname
            item.title = transaction.appFranName
            item.date = transaction.appDate.simpleDateFormat("yyyyMMdd")
            item.time = transaction.appTime
            item.memo = transaction.memo
        } else if let transaction = ManualConsumeRealmProxy().transactionFromIdentity(item.identity) {
            item.category = transaction.category
            item.subCategory = transaction.subCategory
            item.income = transaction.income
            item.outgoing = transaction.outgoing
            item.subTitle = transaction.expedient
            item.title = transaction.contents
            item.date = transaction.date.simpleDateFormat("yyyyMMdd")
            item.time = transaction.time
            item.memo = transaction.memo
        }
        setProperties()
    }
    
    private func convertDate(date: String?, time: String?) -> String? {
        guard let date = date, let time = time else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        guard let itemDate = formatter.date(from: date) else { return "" }
        formatter.dateFormat = "yyyy.MM.dd"
        let dateStr = formatter.string(from: itemDate)
        formatter.dateFormat = "HHmmss"
        guard let itemTimeDate = formatter.date(from: time) else { return "" }
        formatter.dateFormat = "HH:mm"
        let timeStr = formatter.string(from: itemTimeDate)
        return dateStr + " / " + timeStr
    }
    
    @objc private func repairBtnAction() {
        self.viewModel.pushToAddConsumeVC(item: item)
    }
    
    @objc private func removeBtnAction() {
        UIAlertController.presentAlertController(target: self, title: "삭제", massage: "선택하신 내역이 삭제됩니다.\n정말 삭제하시겠습니까?", okBtnTitle: "예", cancelBtn: true, cancelBtnTitle: "아니요") { (_) in
            self.viewModel.removeItem(self.item)
        }
    }
}

// MARK: - Layout

extension DetailConsumeViewController {
    private func layout() {
        consumeMainView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        consumeMainView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        consumeMainView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        consumeMainView.heightAnchor.constraint(equalToConstant: 122).isActive = true
        
        consumeImageView.topAnchor.constraint(equalTo: consumeMainView.topAnchor, constant: 16).isActive = true
        consumeImageView.leadingAnchor.constraint(equalTo: consumeMainView.leadingAnchor, constant: 24).isActive = true
        consumeImageView.widthAnchor.constraint(equalTo: consumeImageView.heightAnchor).isActive = true
        consumeImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        consumeTitleLabel.centerYAnchor.constraint(equalTo: consumeImageView.centerYAnchor).isActive = true
        consumeTitleLabel.leadingAnchor.constraint(equalTo: consumeImageView.trailingAnchor, constant: 8).isActive = true
        
        consumeLabel.trailingAnchor.constraint(equalTo: consumeMainView.trailingAnchor, constant: -24).isActive = true
        consumeLabel.bottomAnchor.constraint(equalTo: consumeMainView.bottomAnchor, constant: -23.2).isActive = true
        
        consumeDetailView.topAnchor.constraint(equalTo: consumeMainView.bottomAnchor, constant: 8).isActive = true
        consumeDetailView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        consumeDetailView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        consumeDetailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        payMethodTitleLabel.topAnchor.constraint(equalTo: consumeDetailView.topAnchor, constant: 36).isActive = true
        payMethodTitleLabel.leadingAnchor.constraint(equalTo: consumeDetailView.leadingAnchor, constant: 24).isActive = true
        payMethodTitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        payMethodLabel.centerYAnchor.constraint(equalTo: payMethodTitleLabel.centerYAnchor).isActive = true
        payMethodLabel.leadingAnchor.constraint(equalTo: payMethodTitleLabel.trailingAnchor, constant: 48).isActive = true
        payMethodLabel.trailingAnchor.constraint(lessThanOrEqualTo: consumeDetailView.trailingAnchor, constant: -24).isActive = true
        payMethodLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        payContentTitleLabel.topAnchor.constraint(equalTo: payMethodLabel.bottomAnchor, constant: 24).isActive = true
        payContentTitleLabel.leadingAnchor.constraint(equalTo: payMethodTitleLabel.leadingAnchor).isActive = true
        payContentTitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        payContentLabel.centerYAnchor.constraint(equalTo: payContentTitleLabel.centerYAnchor).isActive = true
        payContentLabel.leadingAnchor.constraint(equalTo: payMethodLabel.leadingAnchor).isActive = true
        payContentLabel.trailingAnchor.constraint(lessThanOrEqualTo: consumeDetailView.trailingAnchor, constant: -24).isActive = true
        payContentLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        payDateTitleLabel.topAnchor.constraint(equalTo: payContentLabel.bottomAnchor, constant: 24).isActive = true
        payDateTitleLabel.leadingAnchor.constraint(equalTo: payContentTitleLabel.leadingAnchor).isActive = true
        
        payDateLabel.centerYAnchor.constraint(equalTo: payDateTitleLabel.centerYAnchor).isActive = true
        payDateLabel.leadingAnchor.constraint(equalTo: payContentLabel.leadingAnchor).isActive = true
        
        memoTitleLabel.topAnchor.constraint(equalTo: payDateTitleLabel.bottomAnchor, constant: 24).isActive = true
        memoTitleLabel.leadingAnchor.constraint(equalTo: payContentTitleLabel.leadingAnchor).isActive = true
        
        memoLabel.centerYAnchor.constraint(equalTo: memoTitleLabel.centerYAnchor).isActive = true
        memoLabel.leadingAnchor.constraint(equalTo: payDateLabel.leadingAnchor).isActive = true
        
        bottomWhiteView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        bottomWhiteView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomWhiteView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomWhiteView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
