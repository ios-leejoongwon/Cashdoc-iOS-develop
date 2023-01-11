//
//  UIImageView+Extensions.swift
//  Cashdoc
//
//  Created by Oh Sangho on 24/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension UIImageView {
    func arrowImageRotate(isExpand: Bool) {
        if isExpand {
            self.transform = CGAffineTransform(rotationAngle: 180 * .pi / 179.9)
        } else {
            self.transform = CGAffineTransform(rotationAngle: 180 * .pi)
        }
    }
    
    func toLinkImage(with image: String,
                     backgroundColor: UIColor,
                     viewSize: CGFloat,
                     imageSize: CGFloat) {
        
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = viewSize/2
        
        self.widthAnchor.constraint(equalToConstant: viewSize).isActive = true
        self.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        let imageView = UIImageView(image: UIImage(named: image))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
    
    public func loadGif(name: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(name: name)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }

    @available(iOS 9.0, *)
    public func loadGif(asset: String) {
        DispatchQueue.global().async {
            let image = UIImage.gif(asset: asset)
            DispatchQueue.main.async {
                self.image = image
            }
        }
    }
}
