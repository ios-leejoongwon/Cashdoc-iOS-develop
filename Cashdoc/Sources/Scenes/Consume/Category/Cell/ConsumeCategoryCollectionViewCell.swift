//
//  ConsumeCategoryCollectionViewCell.swift
//  Cashdoc
//
//  Created by Taejune Jung on 24/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift

final class ConsumeCategoryCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private var titleName: String?
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.grayCw.cgColor
    }
    private let categoryImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
    }
    private let categoryLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.textAlignment = .center
    }
    private let selectedView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 3
        $0.layer.borderColor = UIColor.blueCw.cgColor
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.selectedView.isHidden = false
            } else {
                self.selectedView.isHidden = true
            }
        }
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        contentView.addSubview(containerView)
        containerView.addSubview(selectedView)
        containerView.addSubview(categoryImage)
        containerView.addSubview(categoryLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func configure(with category: CategoryInfo) {
        categoryImage.image = UIImage(named: self.categoryImageName(with: category))
        categoryLabel.text = category.categoryName
    }
    
    var categoryTitle: String {
        return self.categoryLabel.text ?? "기타"
    }
    
    // MARK: - Private methods

    private func setProperties() {
        selectedView.isHidden = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func categoryImageName(with categoryItem: CategoryInfo) -> String {
        switch categoryItem.categoryTitle {
        case "지출":
            if let outgoing = CategoryManager.shared.outgoingCategoryList {
                let filtered = outgoing.filter({
                    categoryItem.categoryName.contains($0.sub1)
                })
                if let outGoing = CategoryOutgoings(rawValue: filtered.first?.sub1 ?? "미분류") {
                    return outGoing.image
                }
            }
        case "수입":
            if let incomeCate = CategoryManager.shared.incomeCategoryList {
                let filtered = incomeCate.filter({
                    categoryItem.categoryName.contains($0.sub1)
                })
                if let income = CategoryIncomes(rawValue: filtered.first?.sub1 ?? "미분류") {
                    return income.image
                }
            }
        case "기타":
            if let etcCate = CategoryManager.shared.etcCategoryList {
                let filtered = etcCate.filter({
                    categoryItem.categoryName.contains($0.sub1)
                })
                if let etcImage = CategoryEtc(rawValue: filtered.first?.sub1 ?? "미분류") {
                    return etcImage.image
                }
            }
        default:
            break
        }
        return "icQuestionMarkBlack"
    }
}

// MARK: - Layout

extension ConsumeCategoryCollectionViewCell {
    private func layout() {
        
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 48) / 3).isActive = true
        
        selectedView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        selectedView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        selectedView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        selectedView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        categoryImage.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22 * widthRatio).isActive = true
        categoryImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        categoryImage.widthAnchor.constraint(equalToConstant: 25).isActive = true
        categoryImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        categoryLabel.topAnchor.constraint(equalTo: categoryImage.bottomAnchor, constant: 4 * widthRatio).isActive = true
        categoryLabel.centerXAnchor.constraint(equalTo: categoryImage.centerXAnchor).isActive = true
        categoryLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -14 * widthRatio).isActive = true
    }
}
