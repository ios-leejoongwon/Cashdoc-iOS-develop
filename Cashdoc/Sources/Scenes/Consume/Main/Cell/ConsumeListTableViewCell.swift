//
//  ConsumeListTableViewCell.swift
//  Cashdoc
//
//  Created by Taejune Jung on 09/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import AudioToolbox
import AVFoundation

import RxSwift
import RxCocoa

final class ConsumeListTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private var audioPlayer: AVAudioPlayer?
    private var borderViewBottomConstraint: NSLayoutConstraint!
    private var cashViewTopConstraint: NSLayoutConstraint!
    private var cashViewBottomConstraint: NSLayoutConstraint!
    private let pointProvider = CashdocProvider<RewardPointService>()
    
    var contentsItem: ConsumeContentsItem?
    var disposeBag = DisposeBag()
    var touchCount: Int = 0
    var isTouchEnabled: Bool = false
    var cateBtnPushed: (() -> Void)?
    
    // MARK: - UI Componenets
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
        $0.clipsToBounds = true
    }
    private let categoryView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 20
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.grayCw.cgColor
        $0.clipsToBounds = true
    }
    private let categoryImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    let categoryButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
    }
    private let subTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
    }
    private let timeLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
    }
    private let priceLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.textAlignment = .right
    }
    private let borderView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.grayCw.cgColor
    }
    private let etcLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
        $0.textColor = .brownGrayCw
        $0.text = "기타"
        $0.setFontToRegular(ofSize: 12)
        $0.textAlignment = .center
        $0.layer.cornerRadius = 9
        $0.clipsToBounds = true
    }
    let cashView = TapToGetCashView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(containerView)
        containerView.addSubview(borderView)
        containerView.addSubview(categoryView)
        categoryView.addSubview(categoryImageView)
        categoryView.addSubview(categoryButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(priceLabel)
        containerView.addSubview(etcLabel)
        self.addSubview(cashView)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    // MARK: - Internal methods
    func setProperties() {
        contentView.backgroundColor = .grayTwoCw
        self.selectionStyle = .none
    }
    
    func configure(with item: ConsumeContentsItem, isMovedCashViewBottomConstraint: Bool, isConsumeMain: Bool) {
        var item = item
        if item.title == "" {
            item.title = "-"
        }
        subTitleLabel.text = item.subTitle
        timeLabel.text = convertSubTitle(time: item.time)
        
        self.touchCount = item.touchCount
        if self.touchCount >= 20 {
            self.isTouchEnabled = false
        } else {
            self.isTouchEnabled = item.isTouchEnabled
        }
        self.contentsItem = item
        
        if !isTouchEnabled || self.touchCount >= 20 {
            cashView.isHidden = true
            categoryView.isHidden = false
        } else {
            if isConsumeMain {
                cashView.isHidden = false
                categoryView.isHidden = true
            } else {
                cashView.isHidden = true
                categoryView.isHidden = false
            }
        }
        cashView.tapCount = self.touchCount
        
        var imageName = String()
        
        switch item.category {
        case "지출":
            guard let outgoing = CategoryOutgoings(rawValue: item.subCategory) else { return }
            imageName = CategoryConverter.지출(outgoing).image
            titleLabel.text = item.title
            if item.outgoing == 0 {
                priceLabel.text = item.outgoing.commaValue + "원"
            } else {
                priceLabel.text = "-" + item.outgoing.commaValue + "원"
            }
            priceLabel.textColor = .blackCw
            etcLabel.isHidden = true
        case "수입":
            guard let income = CategoryIncomes(rawValue: item.subCategory) else { return }
            imageName = CategoryConverter.수입(income).image
            titleLabel.text = item.title
            priceLabel.text = item.income.commaValue + "원"
            priceLabel.textColor = .blueCw
            etcLabel.isHidden = true
        case "기타":
            guard let etc = CategoryEtc(rawValue: item.subCategory) else { return }
            imageName = CategoryConverter.기타(etc).image
            if item.consumeType == "수기" {
                titleLabel.text = item.title
                if item.income == 0 {
                    priceLabel.text = item.outgoing.commaValue + "원"
                } else {
                    priceLabel.text = item.income.commaValue + "원"
                }
            } else {
                if item.income == 0 {
                    titleLabel.text = "출금/\(item.title)"
                    priceLabel.text = item.outgoing.commaValue + "원"
                } else {
                    titleLabel.text = "입금/\(item.title)"
                    priceLabel.text = item.income.commaValue + "원"
                }
            }
            priceLabel.textColor = .blackCw
            etcLabel.isHidden = false
        default:
            break
        }
        
        if item.cardApprovalGuBun.contains("취소") {
            if let text = priceLabel.text {
                self.priceLabel.attributedText = text.strikeThrough()
            }
        } else {
            if let text = priceLabel.text {
                self.priceLabel.attributedText = text.nonStrikeThrough()
            }
        }
        
        if imageName == "icQuestionMarkBlack" {
            categoryImageView.image = UIImage(named: "icQuestionMarkWhite")
            categoryView.backgroundColor = .grayCw
        } else {
            categoryImageView.image = UIImage(named: imageName)
            categoryView.backgroundColor = .white
        }
        
        categoryButton.addTarget(self, action: #selector(cateAct), for: .touchUpInside)
        
        if item.isLast {
            borderViewBottomConstraint.constant = 0
        } else {
            borderViewBottomConstraint.constant = 4
        }
        self.borderView.layoutIfNeeded()
    }
    
    @objc func cateAct() {
        self.cateBtnPushed?()
    }

    // MARK: - Private methods
    
    private func convertSubTitle(time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmmss"
        if let timeDate = formatter.date(from: time) {
            formatter.dateFormat = "HH:mm"
            let timeStr = formatter.string(from: timeDate)
            return timeStr
        }
        formatter.dateFormat = "HHmm"
        let timeDate = formatter.date(from: time) ?? Date()
        formatter.dateFormat = "HH:mm"
        let timeStr = formatter.string(from: timeDate)
        return timeStr
    }
    
    private func isToday(item: ConsumeContentsItem) -> Bool {
        let toDayDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        if formatter.string(from: toDayDate) == item.date {
            return true
        }
        return false
    }
  
    func setCategoryView(isHidden: Bool) {
        self.categoryView.isHidden = isHidden
    }
}

extension ConsumeListTableViewCell {
    
    private func layout() {
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        containerViewLayout()
    }
    
    private func containerViewLayout() {
        borderView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -4).isActive = true
        borderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        borderViewBottomConstraint = borderView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        borderViewBottomConstraint.constant = 4
        borderViewBottomConstraint.isActive = true
        
        cashViewTopConstraint = cashView.topAnchor.constraint(equalTo: containerView.topAnchor)
        cashViewTopConstraint.constant = 0
        cashViewTopConstraint.isActive = true
        cashView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        cashView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        cashViewBottomConstraint = cashView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        cashViewBottomConstraint.constant = 0
        cashViewBottomConstraint.isActive = true
        
        categoryView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).isActive = true
        categoryView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
        categoryView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        categoryView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        categoryView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        categoryImageView.centerXAnchor.constraint(equalTo: categoryView.centerXAnchor).isActive = true
        categoryImageView.centerYAnchor.constraint(equalTo: categoryView.centerYAnchor).isActive = true
        
        categoryButton.topAnchor.constraint(equalTo: categoryView.topAnchor).isActive = true
        categoryButton.leadingAnchor.constraint(equalTo: categoryView.leadingAnchor).isActive = true
        categoryButton.trailingAnchor.constraint(equalTo: categoryView.trailingAnchor).isActive = true
        categoryButton.bottomAnchor.constraint(equalTo: categoryView.bottomAnchor).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: categoryView.trailingAnchor, constant: 12).isActive = true
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    
        subTitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
        subTitleLabel.leadingAnchor.constraint(equalTo: categoryView.trailingAnchor, constant: 12).isActive = true
        subTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        timeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: subTitleLabel.trailingAnchor, constant: 8).isActive = true
        timeLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
        priceLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16).isActive = true
        priceLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true

        etcLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        etcLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15).isActive = true
        etcLabel.widthAnchor.constraint(equalToConstant: 35).isActive = true
        etcLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        etcLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
