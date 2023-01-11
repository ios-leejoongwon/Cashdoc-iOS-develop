//
//  BasePopupView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 23/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

class BasePopupView: UIView {
    
    // MARK: - Constants
    
    enum Const {
        static let dismissDuration = 0.3
    }
    
    // MARK: - NSLayoutConstraints
    
    var containerViewLeading: NSLayoutConstraint?
    var containerViewTrailing: NSLayoutConstraint?
    var containerViewCenterY: NSLayoutConstraint?
    
    // MARK: - Properties
    
    deinit {
        print("[👋deinit]\(String(describing: self))")
    }
    
    var useContainerView: Bool {
        return true
    }
    var defaultBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.5)
    }
    var containerViewBackgroundColor: UIColor {
        return .white
    }
    var containerViewClipToBound: Bool {
        return true
    }
    var containerViewCornerRadius: CGFloat {
        return 4
    }
    var isDismissEnabledBackgroundTouch: Bool {
        return false
    }
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = defaultBackgroundColor
        if useContainerView {
            bindView()
            containerView.backgroundColor = containerViewBackgroundColor
            containerView.clipsToBounds = containerViewClipToBound
            containerView.layer.cornerRadius = containerViewCornerRadius
            addSubview(containerView)
            layout()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindView() {
        self.rx
            .tapGesture { [weak self] (gestureRecognizer, delegate) in
                gestureRecognizer.delegate = self
            }
            .skip(1)
            .bind { [weak self] _ in
                guard let self = self else { return }
                guard self.isDismissEnabledBackgroundTouch else { return }
                self.dismissView()
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    @objc func dismissView(completion: SimpleCompletion? = nil) {
        UIView.animate(withDuration: Const.dismissDuration, animations: {
            self.alpha = 0.0
        }, completion: { _ in
            self.removeFromSuperview()
            completion?()
        })
    }
}

// MARK: - Layout

extension BasePopupView {
    
    private func layout() {
        containerViewLeading = containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40)
        containerViewTrailing = containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        containerViewCenterY = containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        containerViewLeading?.isActive = true
        containerViewTrailing?.isActive = true
        containerViewCenterY?.isActive = true
    }
    
}

// MARK: - UIGestureRecognizerDelegate

extension BasePopupView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard touch.view?.isDescendant(of: containerView) == true else { return true }
        return false
    }
    
}
