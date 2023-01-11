//
//  DirectInputTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/09.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift

final class DirectInputTableViewCell: UITableViewCell {
    
    // MARK: - UI Componenets
    
    private weak var containerView: UIView!
    private weak var iconImage: UIImageView!
    private weak var addLabel: UILabel!
    private var disposeBag = DisposeBag()
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(type: PropertyCardType) {
        addLabel.text = type.rawValue + " 추가하기"
        iconImage.image = UIImage(named: type.image)
    }
    
    func cellSelected(type: PropertyCardType) {
        containerView.rx.tapGesture().skip(1)
            .bind { (_) in
                switch type {
                case .기타자산:
                    let vc = EtcAddViewController(data: nil)
                    GlobalFunction.pushVC(vc, animated: true)
                case .계좌:
                    let vc = AccountAddViewController()
                    GlobalFunction.pushVC(vc, animated: true)
                case .대출:
                    let vc = LoanAddViewController()
                    GlobalFunction.pushVC(vc, animated: true)
                default:
                    return
                }
        }.disposed(by: disposeBag)
    }
    
    private func setProperties() {
        backgroundColor = .clear
        selectionStyle = .none
        
        containerView = UIView().then {
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.grayCw.cgColor
            $0.backgroundColor = .white
            contentView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(4)
            }
        }
        addLabel = UILabel().then {
            $0.setFontToMedium(ofSize: 16)
            $0.setLineHeight(lineHeight: 24)
            $0.textColor = .blackCw
            containerView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview().inset(30)
                make.centerX.equalToSuperview().offset(16)
            }
        }
        iconImage = UIImageView().then {
            containerView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.width.height.equalTo(24)
                make.centerY.equalTo(addLabel)
                make.trailing.equalTo(addLabel.snp.leading).offset(-8)
            }
        }
    }
    
}
