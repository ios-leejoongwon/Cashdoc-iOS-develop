//
//  UIStackView+Extensions.swift
//  Cashdoc
//
//  Created by Oh Sangho on 24/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension UIStackView {
    func removeExpandView() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
    
    @discardableResult func removeAllArrangedSubviews() -> [UIView] {
        let removedSubviews = arrangedSubviews.reduce([]) { (removedSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            NSLayoutConstraint.deactivate(subview.constraints)
            subview.removeFromSuperview()
            return removedSubviews + [subview]
        }
        return removedSubviews
    }
    
    static func simpleMakeSV(
      _ axis: NSLayoutConstraint.Axis,
      spacing: CGFloat,
      alignment: UIStackView.Alignment = .fill,
      distribution: UIStackView.Distribution = .fill
    ) -> UIStackView {
      let sv: UIStackView = {
        let sv = UIStackView()
        sv.axis = axis
        sv.distribution = distribution
        sv.alignment = alignment
        sv.spacing = spacing
        return sv
      }()
      return sv
    }
}
