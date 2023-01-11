//
//  CouponTableViewCell.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//
import Then

final class CouponTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    var coupon: CouponModel? {
        didSet {
            guard let coupon = coupon else {return}
            
            if let imageUrl = coupon.imageUrl, let url = URL(string: imageUrl) {
                couponImageView.kf.setImage(with: url, placeholder: UIImage(named: "imgCoupon"))
            }
            if let affiliate = coupon.affiliate {
                affiliateLabel.text = affiliate
            }
            if let title = coupon.title {
                titleLabel.text = title
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = SERVER_DATE_FORMAT
            if let expiredAt = coupon.expiredAt {
                dateFormatter.dateFormat = "yyyy.MM.dd"
                let date = Date(timeIntervalSince1970: TimeInterval(expiredAt))
                let convertDate = dateFormatter.string(from: date)
                expireLabel.text = "\(convertDate)까지"
            }
            
            guard let state = coupon.state else {return}
            if state == CouponState.normal.rawValue {
                statusLabel.isHidden = true
                verticalLine.isHidden = true
                blurView.isHidden = true
            } else {
                statusLabel.isHidden = false
                verticalLine.isHidden = false
                statusLabel.text = state == CouponState.used.rawValue ? "사용완료" : "기간만료"
                affiliateLabel.textColor = .warmGray
                titleLabel.textColor = .warmGray
                expireLabel.textColor = .warmGray
                statusLabel.textColor = .warmGray
                blurView.isHidden = false
            }
            
            // 캐시체인지 일때
            if coupon.type == "cashExchange" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = SERVER_DATE_FORMAT
                if let expiredAt = coupon.createdAt {
                    dateFormatter.dateFormat = "yyyy.MM.dd"
                    let date = Date(timeIntervalSince1970: TimeInterval(expiredAt))
                    let convertDate = dateFormatter.string(from: date)
                    expireLabel.text = "\(convertDate) 신청"
                }
                
                if state == CouponState.normal.rawValue {
                    statusLabel.isHidden = false
                    verticalLine.isHidden = false
                    statusLabel.text = "처리중"
                    blurView.isHidden = true
                } else {
                    statusLabel.isHidden = false
                    verticalLine.isHidden = false
                    statusLabel.text = state == CouponState.used.rawValue ? "입금완료" : "입금취소"
                    affiliateLabel.textColor = .warmGray
                    titleLabel.textColor = .warmGray
                    expireLabel.textColor = .warmGray
                    statusLabel.textColor = .warmGray
                    blurView.isHidden = false
                }
            } else if coupon.type == "cashShop" {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = SERVER_DATE_FORMAT
                if let expiredAt = coupon.createdAt {
                    dateFormatter.dateFormat = "yyyy.MM.dd"
                    let date = Date(timeIntervalSince1970: TimeInterval(expiredAt))
                    let convertDate = dateFormatter.string(from: date)
                    expireLabel.text = "\(convertDate) 배송신청"
                }
                
                statusLabel.text = state == CouponState.used.rawValue ? "사용완료" : "배송취소"
            }
        }
    }
    
    // MARK: - UI Components
    private let ticketImageView = UIImageView()
    
    private let couponImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgCoupon")
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    private let affiliateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .warmGray
        $0.setFontToRegular(ofSize: 12)
        $0.textAlignment = .left
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .blackCw
        $0.setFontToMedium(ofSize: 16)
        $0.textAlignment = .left
    }
    private let expireLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .warmGray
        $0.setFontToRegular(ofSize: 12)
        $0.textAlignment = .left
    }
    private let statusLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .blackTwo
        $0.setFontToRegular(ofSize: 12)
        $0.textAlignment = .center
    }
    private let blurView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        $0.isHidden = true
    }
    private let verticalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGray
    }
    private let horizontalLine = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGray
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        addSubview(ticketImageView)
        ticketImageView.addSubview(couponImageView)
        ticketImageView.addSubview(affiliateLabel)
        ticketImageView.addSubview(titleLabel)
        ticketImageView.addSubview(expireLabel)
        ticketImageView.addSubview(statusLabel)
        ticketImageView.addSubview(blurView)
        ticketImageView.addSubview(verticalLine)
        ticketImageView.addSubview(horizontalLine)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        couponImageView.image = UIImage(named: "imgCoupon")
        affiliateLabel.textColor = .warmGray
        titleLabel.textColor = .blackCw
        expireLabel.textColor = .warmGray
        statusLabel.textColor = .azureBlue
        blurView.isHidden = true
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        selectionStyle = .none
                
        if let makeImage = UIImage(named: "couponTicket") {
            let resizable = makeImage.resizableImage(withCapInsets: UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch)
            ticketImageView.image = resizable
        }
    }
    
}

// MARK: - Layout

extension CouponTableViewCell {
    
    private func layout() {
        ticketImageView.snp.makeConstraints { (m) in
            m.top.equalToSuperview().offset(8)
            m.left.right.equalToSuperview().inset(16)
            m.bottom.equalToSuperview()
        }
        
        couponImageView.leadingAnchor.constraint(equalTo: ticketImageView.leadingAnchor, constant: 16).isActive = true
        couponImageView.centerYAnchor.constraint(equalTo: ticketImageView.centerYAnchor).isActive = true
        couponImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        couponImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        affiliateLabel.topAnchor.constraint(equalTo: ticketImageView.topAnchor, constant: 24).isActive = true
        affiliateLabel.leadingAnchor.constraint(equalTo: couponImageView.trailingAnchor, constant: 8).isActive = true
        affiliateLabel.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor, constant: -2).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: affiliateLabel.bottomAnchor, constant: 1).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: couponImageView.trailingAnchor, constant: 8).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor, constant: -2).isActive = true
        
        expireLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 11).isActive = true
        expireLabel.leadingAnchor.constraint(equalTo: couponImageView.trailingAnchor, constant: 8).isActive = true
        expireLabel.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor, constant: -2).isActive = true
        
        statusLabel.trailingAnchor.constraint(equalTo: ticketImageView.trailingAnchor, constant: -4).isActive = true
        statusLabel.centerYAnchor.constraint(equalTo: ticketImageView.centerYAnchor).isActive = true
        statusLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        blurView.topAnchor.constraint(equalTo: ticketImageView.topAnchor).isActive = true
        blurView.leadingAnchor.constraint(equalTo: ticketImageView.leadingAnchor).isActive = true
        blurView.trailingAnchor.constraint(equalTo: verticalLine.leadingAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: ticketImageView.bottomAnchor).isActive = true
        
        verticalLine.topAnchor.constraint(equalTo: ticketImageView.topAnchor).isActive = true
        verticalLine.trailingAnchor.constraint(equalTo: ticketImageView.trailingAnchor, constant: -68).isActive = true
        verticalLine.bottomAnchor.constraint(equalTo: ticketImageView.bottomAnchor).isActive = true
        verticalLine.widthAnchor.constraint(equalToConstant: 1).isActive = true
        
        horizontalLine.leadingAnchor.constraint(equalTo: ticketImageView.leadingAnchor).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: ticketImageView.trailingAnchor).isActive = true
        horizontalLine.bottomAnchor.constraint(equalTo: ticketImageView.bottomAnchor).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}
