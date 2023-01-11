//
//  PropertyTFView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/13.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

enum PropertyTFViewType {
    case textField
    case button
}

class PropertyTFView: UIView {

    weak var cdLabel: UILabel!
    weak var cdTF: UITextField!
    weak var cdBorderView: UIView!

    init(type: PropertyTFViewType, title: String, placeHolder: String) {
        super.init(frame: .zero)
        setProperties(type, title: title, ph: placeHolder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setProperties(_ type: PropertyTFViewType,
                               title: String,
                               ph: String) {
        cdLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.text = title
            addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(24)
            }
        }
        cdBorderView = UIView().then {
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.grayCw.cgColor
            addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(cdLabel.snp.bottom).offset(8)
                make.bottom.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(16)
                make.height.equalTo(56)
            }
        }
        cdTF = UITextField().then {
            $0.font = .systemFont(ofSize: 16)
            $0.placeholder = ph
            if type == .textField {
                $0.clearButtonMode = .whileEditing
            }
            if type == .button {
                let image = UIImageView(image: UIImage(named: "icArrow01StyleDownGray"))
                $0.addSubview(image)
                image.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    make.trailing.equalToSuperview().inset(16)
                    make.size.equalTo(24)
                }
            }
            cdBorderView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.leading.trailing.equalToSuperview().inset(16)
            }
        }
    }

}
