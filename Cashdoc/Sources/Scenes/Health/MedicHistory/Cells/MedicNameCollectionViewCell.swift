//
//  MedicNameCollectionViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/08.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

final class MedicNameCollectionViewCell: CashdocCollectionViewCell {
    
    private weak var nameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            switch isSelected {
            case true:
                nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
                nameLabel.textColor = .blueCw
            case false:
                nameLabel.font = .systemFont(ofSize: 14)
                nameLabel.textColor = .brownishGrayCw
            }
        }
    }
    
    func setupView() {
        nameLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.tag = 1000
            contentView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.center.equalToSuperview()
            }
        }
    }
    
    func configure(_ item: String) {
        nameLabel.text = item
    }
}
