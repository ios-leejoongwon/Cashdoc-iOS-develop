//
//  UIView+Extensions.swift
//  Cashdoc
//
//  Created by Oh Sangho on 04/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension UIView {
    var compatibleSafeAreaLayoutGuide: UILayoutGuide {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide
        } else {
            return layoutMarginsGuide
        }
    }
    
    func mask(_ rect: CGRect, invert: Bool = false) {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        if invert {
            path.addRect(bounds)
        }
        path.addRect(rect)
        maskLayer.path = path
        if invert {
            maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        }
        // Set the mask of the view.
        layer.mask = maskLayer
    }
    
    public func showGuidelines() {
        let value = CGFloat(Int(Date().timeIntervalSince1970) + hash)
        let r = (value.truncatingRemainder(dividingBy: 255)) / 255.0
        let g = ((value / 255).truncatingRemainder(dividingBy: 255)) / 255.0
        let b = CGFloat(hash % 255) / 255.0
        layer.borderColor = UIColor(red: r, green: g, blue: b, alpha: 1).cgColor
        layer.borderWidth = 1.0
        
        subviews.forEach {
            $0.showGuidelines()
        }
    }
    
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
        
        let borderPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let borderLayer = CAShapeLayer()
        borderLayer.path = borderPath.cgPath
        borderLayer.lineWidth = borderWidth
        borderLayer.strokeColor = borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = self.bounds
        self.layer.addSublayer(borderLayer)
    }
    
    public func layoutAnimate(duration: TimeInterval, delay: TimeInterval = 0.0, options: UIView.AnimationOptions = [], animations: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            animations?()
            self.layoutIfNeeded()
        }, completion: { (isFinished) in
            completion?(isFinished)
        })
    }
    
    @IBInspectable
    var IBcornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            // layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable
    var IBborderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var IBborderColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor ?? UIColor.white.cgColor)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    // 특정코너에만 radius주기
    func roundCornersWithLayerMask(cornerRadi: CGFloat, corners: UIRectCorner, customBound: CGRect? = nil) {
        let path = UIBezierPath(roundedRect: customBound ?? bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: cornerRadi, height: cornerRadi))
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }
     
    public func asImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

import Toast

extension UIView {
    func makeToastWithCenter(_ message: String?, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = ToastManager.shared.position, title: String? = nil, image: UIImage? = nil, style: ToastStyle = ToastManager.shared.style, completion: ((_ didTap: Bool) -> Void)? = nil) {
        var customStyle = ToastStyle()
        customStyle.titleAlignment = .center
        customStyle.messageAlignment = .center
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let naviVC = GlobalDefine.shared.curNav {
                if naviVC.viewControllers.count < 2 {
                    let toast = self.createToastActivityView()
                    let bottomPadding: CGFloat = self.safeAreaInsets.bottom
                    let point = CGPoint(x: self.bounds.size.width / 2.0, y: (self.bounds.size.height - (toast.frame.size.height / 2.0)) - (bottomPadding + 100))
                    self.makeToast(message,
                                   point: point,
                                   title: title,
                                   image: image,
                                   completion: completion)
                } else {
                    self.makeToast(message,
                                   duration: duration,
                                   position: position,
                                   title: title,
                                   image: image,
                                   style: customStyle,
                                   completion: completion)
                }
                
            }
        }
    }
    
    func createToastActivityView() -> UIView {
        let style = ToastManager.shared.style
        
        let activityView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: style.activitySize.width, height: style.activitySize.height))
        activityView.backgroundColor = style.activityBackgroundColor
        activityView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        activityView.layer.cornerRadius = style.cornerRadius
        
        if style.displayShadow {
            activityView.layer.shadowColor = style.shadowColor.cgColor
            activityView.layer.shadowOpacity = style.shadowOpacity
            activityView.layer.shadowRadius = style.shadowRadius
            activityView.layer.shadowOffset = style.shadowOffset
        }
        
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.center = CGPoint(x: activityView.bounds.size.width / 2.0, y: activityView.bounds.size.height / 2.0)
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.color = style.activityIndicatorColor
        activityIndicatorView.startAnimating()
        
        return activityView
    }
    
}
