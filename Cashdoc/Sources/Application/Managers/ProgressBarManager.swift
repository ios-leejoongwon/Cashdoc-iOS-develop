//
//  ProgressBarManager.swift
//  Cashdoc
//
//  Created by Oh Sangho on 26/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Lottie
import RxSwift
import RxCocoa

final class ProgressBarManager {
    
    static let shared = ProgressBarManager()
    
    private let containerView = UIView().then {
        $0.tag = 3939
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let animationView = LottieAnimationView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.loopMode = .loop
        $0.backgroundBehavior = .pauseAndRestore
    }
    private var progressHeight: NSLayoutConstraint?
    
    // MARK: - Internal methods
    
    func showProgressBar(vc: UIViewController, isYellow: Bool = false) {
        if vc.view.viewWithTag(3939) == nil {
            vc.view.addSubview(containerView)
            containerView.addSubview(animationView)
            
            if let path = Bundle.main.path(forResource: isYellow ? "progressbar_yellow" : "progressbar_black", ofType: "json") {
                animationView.animation = LottieAnimation.filepath(path)
            }
            
            layout(with: vc)
            DispatchQueue.main.async {
                self.animationView.play()
            }
        }
    }
    
    func hideProgressBar(vc: UIViewController) {
        DispatchQueue.main.async {
            self.animationView.stop()
            self.containerView.removeFromSuperview()
        }
    }
}

// MARK: - Layout

extension ProgressBarManager {
    private func layout(with vc: UIViewController) {
        containerView.topAnchor.constraint(equalTo: vc.view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 2).isActive = true
        
        animationView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
}
