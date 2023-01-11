//
//  CommunityMenuCollectionCell.swift
//  Cashdoc
//
//  Created by 이아림 on 2021/10/14.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Foundation
import UIKit

class CommunityMenuCollectionCell: CashdocCollectionViewCell {
     
    private var titleLabel: UILabel!
    private var chatImageView: UIImageView!
     
    func setupView() {
        contentView.backgroundColor = .white
        contentView.layer.addBorder([.top, .bottom, .right, .left], color: .grayFourCw, width: 0.5, viewSize: contentView.bounds.size)
        
        let stackView = UIStackView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.distribution = .fill
            $0.spacing = 3
            contentView.addSubview($0)
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        
        chatImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = UIImage(named: "icOpenchatGray")
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
            stackView.addArrangedSubview($0)
        }
        
        titleLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.adjustsFontSizeToFitWidth = true
            $0.minimumScaleFactor = 12
            stackView.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(20)
            }
        }
    }
    
    func drawCell(_ type: AvocatalkCategoryModel, isSel: Bool) { 
        titleLabel.text = type.name
        titleLabel.font = isSel ? UIFont.boldSystemFont(ofSize: 14) : UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = isSel ? .blackCw : .brownishGrayCw 
        if type.type == AvocatalkCategoryModel.LinkType.chat.rawValue {
            chatImageView.isHidden = false
            chatImageView.image = isSel ? UIImage(named: "icOpenchatBlack") : UIImage(named: "icOpenchatGray")
            if let text = titleLabel.text, text.count > 7 {
                titleLabel.snp.makeConstraints {
                    $0.width.lessThanOrEqualTo(97)
                }
            }
        } else {
            chatImageView.isHidden = true
            if let text = titleLabel.text, text.count > 9 {
                titleLabel.snp.makeConstraints {
                    $0.width.lessThanOrEqualTo(117)
                }
            }
        }
    }
}
