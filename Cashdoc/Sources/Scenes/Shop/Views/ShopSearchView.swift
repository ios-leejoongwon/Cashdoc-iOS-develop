//
//  ShopSearchView.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

import Then

protocol ShopSearchViewDelegate: NSObjectProtocol {
    func shoppingSearchViewDidClickedSearchButton(_ view: ShopSearchView)
    func shoppingSearchViewDidChangeText(_ view: ShopSearchView)
}

final class ShopSearchView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: ShopSearchViewDelegate?
    
    // MARK: - UI Components
    
    private let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    private let iconSearchImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icSearchGray")
        $0.contentMode = .scaleAspectFit
    }
    private let deleteButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "btnDelete"), for: .normal)
        $0.isHidden = true
    }
    let textField = UITextField().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.placeholder = "카테고리 내 검색"
        $0.text = ""
        $0.returnKeyType = .search
        $0.font = UIFont.systemFont(ofSize: 14 * widthRatio, weight: .medium)
        $0.textAlignment = .left
        $0.backgroundColor = .white
    }
    
    // MARK: - Overridden: UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        addSubview(contentView)
        contentView.addSubview(iconSearchImageView)
        contentView.addSubview(textField)
        contentView.addSubview(deleteButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        clipsToBounds = true
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        deleteButton.addTarget(self, action: #selector(didClickedDeleteButton), for: .touchUpInside)
    }
    
    // MARK: - Private selector
    
    @objc private func didClickedDeleteButton() {
        textField.text = ""
    }
    
}

// MARK: - Layout

extension ShopSearchView {
    
    private func layout() {
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 9).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        iconSearchImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        iconSearchImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        iconSearchImageView.setContentHuggingPriority(.required, for: .horizontal)
        iconSearchImageView.setContentHuggingPriority(.required, for: .vertical)
        
        textField.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        textField.leadingAnchor.constraint(equalTo: iconSearchImageView.trailingAnchor, constant: 8).isActive = true
        textField.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8).isActive = true
        
        deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        deleteButton.widthAnchor.constraint(equalTo: deleteButton.heightAnchor, multiplier: 1).isActive = true
    }
    
}

// MARK: - UITextFieldDelegate

extension ShopSearchView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.shoppingSearchViewDidClickedSearchButton(self)
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            deleteButton.isHidden = true
        } else {
            deleteButton.isHidden = false
        }
        delegate?.shoppingSearchViewDidChangeText(self)
    }
}
