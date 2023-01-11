//
//  InitialView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 19/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class InitialView: UIView {
    
    // MARK: - UIComponents
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    private let imageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFill
    }
    
    // MARK: - Con(De)structor
    
    init(title: String,
         subTitle: String,
         imageName: String) {
        super.init(frame: .zero)
        setProperties(title: title, subTitle: subTitle, imageName: imageName)
        addSubview(imageView)
        addSubview(titleLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private methods
    
    private func setProperties(title: String, subTitle: String, imageName: String) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 36
        paragraph.alignment = .center
        let titleAtributedStr = NSMutableAttributedString(string: title,
                                                          attributes: [.font: UIFont.systemFont(ofSize: 24 * widthRatio, weight: .medium),
                                                                       .foregroundColor: UIColor.blackCw,
                                                                       .kern: 0.0])
        titleAtributedStr.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: titleAtributedStr.length))
        let range = (titleAtributedStr.string as NSString).range(of: subTitle)
        titleAtributedStr.addAttributes([.foregroundColor: UIColor.blueCw], range: range)
        
        titleLabel.attributedText = titleAtributedStr
        
        imageView.image = UIImage(named: imageName)
    }
}

// MARK: - Layout

extension InitialView {
    private func layout() {
        // imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        if ScreenSize.HEIGHT > 736 {
            titleLabel.topAnchor.constraint(equalTo: compatibleSafeAreaLayoutGuide.topAnchor, constant: 122).isActive = true
            imageView.bottomAnchor.constraint(equalTo: compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -102).isActive = true
        } else if ScreenSize.HEIGHT == 568 {
            titleLabel.topAnchor.constraint(equalTo: compatibleSafeAreaLayoutGuide.topAnchor, constant: 76).isActive = true
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 100).isActive = true
        } else {
            titleLabel.topAnchor.constraint(equalTo: compatibleSafeAreaLayoutGuide.topAnchor, constant: 92).isActive = true
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30).isActive = true
        }
        titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
