//
//  PropertyCommonCardTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2019/11/28.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxGesture
import RxCocoa
import SnapKit

final class PropertyCommonCardTableViewCell: CardBaseTableViewCell {
    
    // MARK: - Properties
    
    var containerViewTapGesture: TapControlEvent {
        return containerView.rx.tapGesture()
    }
    private var containerHeight: ConstraintMakerExtendable!
    private var beforeLinkedView: PropertyBeforeLinkCardView?
    
    // MARK: - UI Componenets
    
    private let afterLinkedView = UIView()
    private let leftIconImage = UIImageView()
    private let leftTitleLabel = UILabel().then {
        $0.setFontToMedium(ofSize: 18)
        $0.textColor = .blackCw
    }
    private let rightLabel = UILabel().then {
        $0.setFontToMedium(ofSize: 16)
    }
    private let arrowImage = UIImageView().then {
        $0.image = UIImage(named: "icArrow01StyleRightGray")
    }
    private let insCountView = UIView().then {
        $0.backgroundColor = .veryLightPinkFourCw
        $0.layer.cornerRadius = 12
        $0.isHidden = true
    }
    private let insCountLabel = UILabel().then {
        $0.setFontToRegular(ofSize: 12)
        $0.setLineHeight(lineHeight: 18)
        $0.textColor = .brownGrayCw
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.addSubview(afterLinkedView)
        afterLinkedView.addSubview(leftIconImage)
        afterLinkedView.addSubview(leftTitleLabel)
        afterLinkedView.addSubview(rightLabel)
        afterLinkedView.addSubview(arrowImage)
        afterLinkedView.addSubview(insCountView)
        insCountView.addSubview(insCountLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func configure(with item: PropertyExpandCommon) {
        leftTitleLabel.text = item.type.rawValue
        leftIconImage.image = UIImage(named: item.type.image)
        switch item.type {
        case .캐시:
            if let item = item as? PropertyExpandCash {
                didChangeLinkedView(isEmpty: false)
                insCountView.isHidden = true
                rightLabel.text = String(format: "%@캐시", item.point.commaValue)
            }
        case .신용:
            if let item = item as? PropertyExpandCredit {
                setBeforeLinkedView(type: .신용)
                didChangeLinkedView(isEmpty: item.rating.isEmpty)
                insCountView.isHidden = true
                rightLabel.text = String(format: "%@등급 (%@점)", item.rating, item.score)
            }
        case .보험:
            if let item = item as? PropertyExpandInsurance {
                let getInsuRealm = InsuranListRealmProxy().getTotalAndPerson()
                setBeforeLinkedView(type: .보험)
                let isLinked = getInsuRealm.count > 0
                didChangeLinkedView(isEmpty: !isLinked)
                insCountView.isHidden = false
                insCountLabel.text = item.insCount.commaValue
                if getInsuRealm.count > 0, !UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinked내보험다나와.rawValue) {
                    arrowImage.image = UIImage(named: "icCautionColor")
                } else {
                    arrowImage.image = UIImage(named: "icArrow01StyleRightGray")
                }
                rightLabel.text = String(format: "월 %@ 납부", item.insTotalAmt.commaValue)
            }
        default:
            return
        }
    }
    
    private func setBeforeLinkedView(type: PropertyCardType) {
        if beforeLinkedView == nil {
            switch type {
            case .신용, .보험:
                beforeLinkedView = PropertyBeforeLinkCardView(propertyType: type)
                if let beforeLinkedView = beforeLinkedView {
                    containerView.addSubview(beforeLinkedView)
                    beforeLinkedView.snp.makeConstraints { (make) in
                        make.edges.equalToSuperview()
                    }
                }
            default:
                return
            }
        }
    }
    
    private func didChangeLinkedView(isEmpty: Bool) {
        if !isEmpty {
            beforeLinkedView?.isHidden = true
            afterLinkedView.isHidden = false
            containerView.snp.updateConstraints { (make) in
                make.height.equalTo(72)
            }
        } else {
            beforeLinkedView?.isHidden = false
            afterLinkedView.isHidden = true
            containerView.snp.updateConstraints { (make) in
                make.height.equalTo(94)
            }
        }
    }
    
}

// MARK: - Layout

extension PropertyCommonCardTableViewCell {
    
    private func layout() {
        afterLinkedView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        leftIconImage.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalToSuperview().inset(24)
            make.width.height.equalTo(24).priority(.high)
        }
        leftTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(leftIconImage)
            make.leading.equalTo(leftIconImage.snp.trailing).offset(12)
        }
        arrowImage.snp.makeConstraints { (make) in
            make.centerY.equalTo(leftIconImage)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        rightLabel.snp.makeConstraints {(make) in
            make.centerY.equalTo(leftIconImage)
            make.trailing.equalTo(arrowImage.snp.leading).offset(-4.9)
            make.leading.greaterThanOrEqualTo(leftTitleLabel.snp.trailing).offset(16)
        }
        insCountView.snp.makeConstraints { (make) in
            make.centerY.equalTo(leftIconImage)
            make.leading.equalTo(leftTitleLabel.snp.trailing).offset(13.4)
            make.height.equalTo(24)
        }
        insCountLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(3)
            make.leading.trailing.equalToSuperview().inset(8.5)
        }
    }
    
}
