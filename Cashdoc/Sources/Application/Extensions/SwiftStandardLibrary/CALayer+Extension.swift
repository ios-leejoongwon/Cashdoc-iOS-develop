//
//  CALayer+Extension.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/17.
//  Copyright © 2020 Cashwalk. All rights reserved.
//
extension CALayer {
    // 원하는곳에만 border추가하기
    func addBorder(_ arr_edge: [UIRectEdge], color: UIColor, width: CGFloat, viewSize: CGSize) {
        for edge in arr_edge {
            let border = CALayer()
            switch edge {
            case UIRectEdge.top:
                border.frame = CGRect.init(x: 0, y: 0, width: viewSize.width, height: width)
            case UIRectEdge.bottom:
                border.frame = CGRect.init(x: 0, y: viewSize.height - width, width: viewSize.width, height: width)
            case UIRectEdge.left:
                border.frame = CGRect.init(x: 0, y: 0, width: width, height: viewSize.height)
            case UIRectEdge.right:
                border.frame = CGRect.init(x: viewSize.width - width, y: 0, width: width, height: viewSize.height)
            default:
                break
            }
            border.backgroundColor = color.cgColor
            self.addSublayer(border)
        }
    }
}
