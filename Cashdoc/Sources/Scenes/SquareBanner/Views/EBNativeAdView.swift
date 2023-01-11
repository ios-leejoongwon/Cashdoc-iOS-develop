//
//  EBNativeAdView.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/09/27.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import ExelBidSDK

/**
 - ``@interface EBNativeAdView : UIView<EBNativeAdRendering>`` // 네이티브 광고가 노출 되어야 하는 View를 설정합니다. 광고요청시 설정되는 항목으로는 제목, 상세설명, 메인이미지, 아이콘, 별점, 액션 버튼의 텍스트가 있으며, 어플리케이션에서 사용할 항목만 NativeView에 설정하면 됩니다.
 - ``(UIImageView *)nativeMainImageView`` //생성자에 설정한 View에 포함되어 있는 광고의 메인 이미지가 노출될 ImageView의 id를 설정합니다.
 - ``(UILabel *)nativeCallToActionTextLabel``  //생성자에 설정한 View에 포함되어 있는 광고의 ActionButton id를 설정합니다. 해당 Button에 텍스트가 설정 됩니다.
 - ``(UILabel *)nativeTitleTextLabel`` //생성자에 설정한 View에 포함되어 있는 광고의 제목이 설정 될 TextView의 id를 설정합니다.
 - ``(UILabel *)nativeMainTextLabel`` //생성자에 설정한 View에 포함되어 있는 광고의 설명이 설정 될 TextView의 id를 설정합니다.
 - ``(UIImageView *)nativeIconImageView``  //생성자에 설정한 View에 포함되어 있는 광고의 아이콘이 노출될 ImageView의 id를 설정합니다.
 - ``(void)layoutStarRating:(NSNumber *)starRating`` // 생성자에 설정한 View에 포함되어 있는 광고의 별점이 표시될 RatingBar의 id를 설정합니다.
 - ``(UIImageView *)nativePrivacyInformationIconImageView`` // 생성자에 설정한 View에 포함되어 있는 광고 정보 표시 아이콘이 노출될 ImageView를 설정합니다. 해당 ImageView의 속성에 기본 Info 아이콘이 바이딩 됩니다.
 */
class EBNativeAdView: UIView, EBNativeAdRendering {
    
    var titleLabel: UILabel!
    var mainTextLabel: UILabel!
    var mainImageView: UIImageView!
    var iconImageView: UIImageView!
    var ctaLabel: UILabel!
    var privacyInformationIconImageView: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    func setupView() {
        backgroundColor = .white
         
        mainImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFill
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(300)
                m.height.equalTo(156)
                m.top.leading.equalToSuperview()
            }
        }
         
        let stackH = UIStackView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .horizontal
            $0.spacing = 8
            $0.clipsToBounds = true
            $0.distribution = .fill
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(40)
                m.top.equalTo(mainImageView.snp.bottom).offset(18)
                m.leading.trailing.equalToSuperview().inset(12)
            }
        }
        
        iconImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { m in
                m.width.equalTo(40)
            }
        }
        stackH.addArrangedSubview(iconImageView)
        
        let stackV = UIStackView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .vertical
            $0.spacing = 2
            $0.distribution = .equalSpacing
            $0.clipsToBounds = true
            stackH.addArrangedSubview($0)
        }
        
        titleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.boldSystemFont(ofSize: 13.0)
            $0.text = "Title"
            $0.numberOfLines = 1
            stackV.addArrangedSubview($0)
        }
        
        mainTextLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.systemFont(ofSize: 13.0)
            $0.text = "Text"
            $0.numberOfLines = 1
            stackV.addArrangedSubview($0)
        }
         
        ctaLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.boldSystemFont(ofSize: 14.0)
            $0.text = "CTA Text"
            $0.textColor = .blackCw
            $0.textAlignment = .center
            $0.backgroundColor = .yellowCw
            $0.numberOfLines = 1
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(stackH.snp.bottom).offset(18)
                m.trailing.leading.bottom.equalToSuperview()
            }
        }
         
        privacyInformationIconImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
            $0.contentMode = .scaleAspectFit
            $0.image = UIImage(named: "icAd")
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(24)
                m.height.equalTo(20)
                m.top.equalTo(mainImageView.snp.top)
                m.leading.equalTo(mainImageView.snp.leading)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - <MPNativeAdRendering>

    func nativeMainTextLabel() -> UILabel? {
        return mainTextLabel
    }

    func nativeTitleTextLabel() -> UILabel? {
        return titleLabel
    }
    
    func nativeMainImageView() -> UIImageView? {
        return mainImageView
    }
    
    func nativeIconImageView() -> UIImageView? {
        return iconImageView
    }
    func nativeCallToActionTextLabel() -> UILabel? {
        return ctaLabel
    }
    func nativePrivacyInformationIconImageView() -> UIImageView? {
        return privacyInformationIconImageView
    }
}
