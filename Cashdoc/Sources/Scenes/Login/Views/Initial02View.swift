//
//  Initial02View.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/11/09.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation 

final class Initial02View: UIView {
    
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
        paragraph.minimumLineHeight = 26
        paragraph.alignment = .center
        
        let title00 = "최대 1,000만 캐시의\n행운을 받아가세요!"
        let titleAtributedStr = NSMutableAttributedString(string: title00,
                                                          attributes: [.font: UIFont.systemFont(ofSize: 22 * widthRatio, weight: .regular),
                                                                       .foregroundColor: UIColor.blackCw,
                                                                       .kern: 0.0])
        titleAtributedStr.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: titleAtributedStr.length))
        let range = (titleAtributedStr.string as NSString).range(of: "최대 1,000만 캐시")
        titleAtributedStr.addAttributes([.font: UIFont.systemFont(ofSize: 22 * widthRatio, weight: .bold), .foregroundColor: UIColor.blueCw], range: range)
        titleLabel01.attributedText = titleAtributedStr
         
        imageView.image = UIImage(named: "imgTutorial02")
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
        
        titleLabel = UILabel().then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.text = "캐시로또는\nMBC 토요일 8시 35분에 발표되는\n로또 6/45와 동일한 번호로 당첨돼요!"
            $0.font = .systemFont(ofSize: 18)
            $0.textColor = .blackCw 
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalToSuperview()
                if ScreenSize.HEIGHT > 736 {
                    m.top.equalTo(self.snp.top).offset(100)
                } else {
                    m.top.equalTo(self.snp.top).offset(86)
                }
            }
            
        }
          
        titleLabel01 = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textAlignment = .center
            $0.numberOfLines = 0
            addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerX.equalToSuperview()
                m.top.equalTo(titleLabel.snp.bottom).offset(20)
            }
            
        }
        
    }
}
