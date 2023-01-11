//
//  ResizableImageView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 11/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class ResizableImageView: UIImageView {
    
    override var image: UIImage? {
        didSet {
            guard let image = image else { return }
            
            let resizeConstraints = [
                self.heightAnchor.constraint(equalToConstant: image.size.height),
                self.widthAnchor.constraint(equalToConstant: image.size.width)
            ]
            
            if superview != nil {
                addConstraints(resizeConstraints)
            }
        }
    }
}
