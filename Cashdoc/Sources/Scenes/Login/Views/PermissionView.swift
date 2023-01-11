//
//  PermissionView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class PermissionView: UIView {
    
    // MARK: - UIComponents
    
    private let permissionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.blackCw
        label.numberOfLines = 0
        return label
    }()
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.brownGrayCw
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Con(De)structor
    
    init(title: String, subTitle: String, imageName: String) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setProperties(title: title, subTitle: subTitle, name: imageName)
        self.addSubview(permissionImageView)
        self.addSubview(titleLabel)
        self.addSubview(subTitleLabel)
        
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private methods
    
    private func setProperties(title: String, subTitle: String, name: String) {
        
        permissionImageView.image = UIImage(named: name)
        titleLabel.setFontToMedium(ofSize: 14)
        titleLabel.text = title
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 4
        let attributedString = NSMutableAttributedString(string: subTitle, attributes: [
            .font: UIFont.systemFont(ofSize: 12 * widthRatio, weight: .regular),
            .kern: 0.0
            ])
        attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attributedString.length))
        subTitleLabel.attributedText = attributedString
    }
}

extension PermissionView {
    
    private func layout() {
        permissionImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        permissionImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 9).isActive = true
        permissionImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        permissionImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: permissionImageView.trailingAnchor, constant: 16).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2).isActive = true
        subTitleLabel.leadingAnchor.constraint(equalTo: permissionImageView.trailingAnchor, constant: 16).isActive = true
        subTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
    }
    
}
