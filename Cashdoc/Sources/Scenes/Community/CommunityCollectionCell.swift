//
//  CommCollectionCell.swift
//  Cashdoc
//
//  Created by 이아림 on 2021/10/08.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Foundation
import UIKit

class CommunityCollectionCell: CashdocCollectionViewCell {
    // MARK: Private

    private var titleLabel: UILabel!
    private var footerLineView: UIView!
     
    func setupView() {
        contentView.backgroundColor = .white
        
        titleLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 16)
            contentView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.center.equalToSuperview()
            }
        }
        
        footerLineView = UIView().then {
            $0.backgroundColor = .blackCw
            $0.isHidden = true
            contentView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.left.right.equalToSuperview()
                m.top.equalTo(titleLabel.snp.bottom).offset(11)
                m.height.equalTo(3)
            }
        }
    }
    
    func drawCell(_ type: AvocatalkCategoryModel, isSel: Bool) {
      titleLabel.text = type.name
      if isSel {
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .blackCw
        footerLineView.isHidden = false
      } else {
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.textColor = .brownishGrayCw
        footerLineView.isHidden = true
      }
    }
}
