//
//  GameDataPopupView.swift
//  Cashwalk
//
//  Created by cashwalk on 2018. 6. 25..
//  Copyright © 2018년 Cashwalk, Inc. All rights reserved.
//

import Then

final class GameDataPopupView: BasePopupView {

    // MARK: - UI Components
    
    private let backgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "게임 실행 시 WiFi상태가 아닐 경우\n데이터가 차감될 수 있습니다."
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor.fromRGB(117, 117, 117)
        $0.numberOfLines = 0
    }
    private let closeButton = UIButton(type: .system).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.fromRGB(94, 80, 80)
        $0.setTitle("닫기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        $0.titleLabel?.textAlignment = .center
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        addSubview(backgroundView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(closeButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        closeButton.addTarget(self, action: #selector(didClickedCloseButton), for: .touchUpInside)
    }
    
    // MARK: - Private selector
    
    @objc private func didClickedCloseButton() {
        dismissView()
    }
}

// MARK: - Layout

extension GameDataPopupView {
    
    private func layout() {
        backgroundView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        backgroundView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        backgroundView.widthAnchor.constraint(equalToConstant: 280).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 167).isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 36).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        
        closeButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 18).isActive = true
        closeButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
}
