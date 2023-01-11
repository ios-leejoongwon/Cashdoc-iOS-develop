//
//  Initial01View.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/11/09.
//  Copyright © 2022 Cashwalk. All rights reserved.
//
import Foundation

final class Initial01View: UIView {
    
    // MARK: - UIComponents
    
    private var titleLabel: UILabel!
    private var titleLabel01: UILabel!
    private var imageView: UIImageView!
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(frame: .zero)
        layout()
        setProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private methods
    
    private func setProperties() {
        
        let paragraph = NSMutableParagraphStyle()
        if ScreenSize.HEIGHT > 736 {
            paragraph.minimumLineHeight = 36
        } else {
            paragraph.minimumLineHeight = 32
        }
        paragraph.alignment = .center
        
        let title00 = "지금 바로 사용 가능한\n1,000캐시 도착!"
        var titleAtributedStr = NSMutableAttributedString(string: title00,
                                                          attributes: [.font: UIFont.systemFont(ofSize: 22 * widthRatio, weight: .regular),
                                                                       .foregroundColor: UIColor.blackCw,
                                                                       .kern: 0.0])
        titleAtributedStr.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: titleAtributedStr.length))
        var range = (titleAtributedStr.string as NSString).range(of: "1,000캐시")
        titleAtributedStr.addAttributes([.font: UIFont.systemFont(ofSize: 22 * widthRatio, weight: .bold), .foregroundColor: UIColor.blueCw], range: range)
        titleLabel.attributedText = titleAtributedStr
        
        let title01 = "최대 1천만 캐시 당첨 가능한\n캐시로또 500장까지!"
        titleAtributedStr = NSMutableAttributedString(string: title01,
                                                          attributes: [.font: UIFont.systemFont(ofSize: 22 * widthRatio, weight: .regular),
                                                                       .foregroundColor: UIColor.blackCw,
                                                                       .kern: 0.0])
        titleAtributedStr.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: titleAtributedStr.length))
        range = (titleAtributedStr.string as NSString).range(of: "캐시로또 500장")
        titleAtributedStr.addAttributes([.font: UIFont.systemFont(ofSize: 22 * widthRatio, weight: .bold), .foregroundColor: UIColor.blueCw], range: range)
        
        titleLabel01.attributedText = titleAtributedStr
        
        imageView.image = UIImage(named: "imgTutorial01")
    }
     
    // MARK: - Layout
    private func layout() {
        
        imageView = UIImageView().then {
            $0.contentMode = .scaleAspectFill
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.left.right.equalToSuperview()
                if ScreenSize.HEIGHT > 736 {
                    m.bottom.equalTo(self.snp.bottom).offset(-102)
                } else {
                    m.bottom.equalToSuperview()
                }
            }
        }
        
        let subtitle01 = UILabel().then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.text = "최초 가입시"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .brownGrayTwoCw
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalToSuperview()
                Log.al("ScreenSize.HEIGHT = \(ScreenSize.HEIGHT)")
                if ScreenSize.HEIGHT > 736 {
                    m.top.equalTo(self.snp.top).offset(100)
                } else {
                    m.top.equalTo(self.snp.top).offset(76)
                }
            }
        }
        
        titleLabel = UILabel().then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalToSuperview()
                m.top.equalTo(subtitle01.snp.bottom).offset(6) 
            }
            
        }
        
        let subtitle = UILabel().then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.text = "*가입 시 500캐시 + 추천인 코드 입력 시 500캐시"
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .brownGrayTwoCw
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalToSuperview()
                m.top.equalTo(titleLabel.snp.bottom).offset(4)
            }
            
        }
        
        titleLabel01 = UILabel().then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalToSuperview()
                if ScreenSize.HEIGHT > 736 {
                    m.top.equalTo(subtitle.snp.bottom).offset(18)
                } else {
                    m.top.equalTo(subtitle.snp.bottom).offset(10)
                }
            }
            
        }
        
        _ = UIImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.image = UIImage(named: "imgTutorialContext01")
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalToSuperview()
                if #available(iOS 13.0, *) {
                    if ScreenSize.HEIGHT > 736 {
                        m.bottom.equalTo(self.snp.bottomMargin).offset(-182)
                    } else {
                        m.bottom.equalTo(self.snp.bottomMargin).offset(-149)
                    }
                } else {
                    m.bottom.equalTo(self.snp.bottomMargin).offset(-126)
                }
            }
        }
        
    }
}
