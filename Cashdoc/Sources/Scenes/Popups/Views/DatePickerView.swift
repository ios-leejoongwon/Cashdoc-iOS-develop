//
//  DatePickerView.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/04/12.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit

import Then

protocol DatePickerViewDelegate: NSObjectProtocol {
    func datePickerViewDidDismissed(_ view: DatePickerView)
    func datePickerView(_ view: DatePickerView, didClickedOkButton date: Date)
}

final class DatePickerView: UIView {
    
    // MARK: - Properties
    
    private let titleView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.textColor = .blackTwoCw
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    private let okButton = UIButton(type: .system).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setTitle("확인", for: .normal)
    }
    private let datePicker = UIDatePicker().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.date = Date(year: 1985, month: 1, day: 1)
        $0.minimumDate = Date(year: 1900, month: 1, day: 1)
        $0.maximumDate = Date()
        $0.minuteInterval = 1
        $0.datePickerMode = .date
        if #available(iOS 13.4, *) {
            $0.preferredDatePickerStyle = .wheels
            $0.subviews.first?.backgroundColor = .white
        }
    }
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
    
    weak var delegate: DatePickerViewDelegate?
    
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
        setProperties()
        setSelector()
        addSubview(titleView)
        addSubview(datePicker)
        titleView.addSubview(titleLabel)
        titleView.addSubview(okButton)
        layout()
        
        titleLabel.text = "생일"
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = UIColor.black.withAlphaComponent(0.25)
        tapGestureRecognizer.delegate = self
    }
    
    private func setSelector() {
        addGestureRecognizer(tapGestureRecognizer)
        okButton.addTarget(self, action: #selector(okButtonDidClicked), for: .touchUpInside)
    }
    
    // MARK: - Private selector
    
    @objc private func dismissView() {
        removeFromSuperview()
        delegate?.datePickerViewDidDismissed(self)
    }
    
    @objc private func okButtonDidClicked() {
        delegate?.datePickerView(self, didClickedOkButton: datePicker.date)
        dismissView()
    }
    
}

// MARK: - Layout

extension DatePickerView {
    
    private func layout() {
        titleView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        titleView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleView.bottomAnchor.constraint(equalTo: datePicker.topAnchor).isActive = true
        
        datePicker.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        datePicker.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        layoutTitleView()
    }
    
    private func layoutTitleView() {
        titleLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        okButton.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        okButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -16).isActive = true
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension DatePickerView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = touch.view else {return false}
        guard view.isDescendant(of: titleView) == false, view.isDescendant(of: datePicker) == false else {return false}
        return true
    }
    
}
