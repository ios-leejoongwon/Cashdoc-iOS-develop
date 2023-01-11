//
//  TutorialRightTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 23/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class TutorialRightTableViewCell: CashdocTableViewCell {
    
    // MARK: - Properties
    
    var isLeftBtnFlag: Bool = true
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let dialogView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .yellowCw
        $0.layer.cornerRadius = 16
    }
    private let tailImage = ResizableImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgBallloonRight")
    }
    private let answerLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(containerView)
        containerView.addSubview(tailImage)
        containerView.addSubview(dialogView)
        containerView.addSubview(answerLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func configure(with answer: String) {
        answerLabel.text = answer
        animatedShowContentView()
    }
    
    private func setProperties() {
        contentView.backgroundColor = .veryLightPinkThreeCw
        containerView.alpha = 0
    }
    
    private func animatedShowContentView() {
        UIView.animate(withDuration: 0.25) {
            self.containerView.alpha = 1
        }
    }
    
}

// MARK: - Layout

extension TutorialRightTableViewCell {
    private func layout() {
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        containerViewLayout()
    }
    
    private func containerViewLayout() {
        dialogView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        dialogView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        dialogView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -11).isActive = true
        
        tailImage.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        tailImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -7).isActive = true
        
        answerLabel.topAnchor.constraint(equalTo: dialogView.topAnchor, constant: 8).isActive = true
        answerLabel.bottomAnchor.constraint(equalTo: dialogView.bottomAnchor, constant: -8).isActive = true
        answerLabel.leadingAnchor.constraint(equalTo: dialogView.leadingAnchor, constant: 14).isActive = true
        answerLabel.trailingAnchor.constraint(equalTo: dialogView.trailingAnchor, constant: -14).isActive = true
        answerLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
}
