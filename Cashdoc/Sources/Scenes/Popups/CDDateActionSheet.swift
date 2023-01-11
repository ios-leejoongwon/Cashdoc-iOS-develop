//
//  CDDateActionSheet.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/13.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

class CDDateActionSheet: CashdocViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var getStackView: UIStackView!
    @IBOutlet weak var getScrollView: UIScrollView!
    @IBOutlet weak var completeButton: UIButton!
    
    var getTitleString = ""
    var didSelectDate: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setProperty()
        self.bindView()
    }
    
    private func setProperty() {
        if getTitleString.isEmpty {
            titleLabel.text = self.dateFormatting().string(from: Date())
        } else {
            titleLabel.text = getTitleString
        }
        completeButton.setTitleColor(.blackCw, for: .normal)
        
        _ = UIDatePicker().then {
            $0.datePickerMode = .date
            if #available(iOS 13.4, *) {
                $0.preferredDatePickerStyle = .wheels
            }
            $0.backgroundColor = .white
            $0.locale = .init(identifier: GlobalFunction.getLocaleID())
            $0.date = dateFormatting().date(from: getTitleString) ?? Date()
            $0.addTarget(self, action: #selector(changed), for: .valueChanged)
            getStackView.addArrangedSubview($0)
        }

        self.view.layoutIfNeeded()
    }
    
    private func bindView() {
        getScrollView.setContentOffset(CGPoint(x: 0, y: getStackView.frame.height), animated: false)
        titleView.roundCornersWithLayerMask(cornerRadi: 8, corners: [.topLeft, .topRight])
        
        getScrollView.rx.didEndDragging.bind { [weak self] endBool in
            guard let self = self else {return}
            if !endBool, self.getScrollView.contentOffset.y < self.getStackView.frame.height {
                self.getScrollView.setContentOffset(CGPoint.zero, animated: true)
            }
        }.disposed(by: disposeBag)
        
        getScrollView.rx.didScroll.bind { [weak self] _ in
            guard let self = self else {return}
            if self.getScrollView.contentOffset == CGPoint.zero {
                self.closeAct()
            }
        }.disposed(by: disposeBag)
        
        completeButton.rx.tap
            .bind(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.didSelectDate?(self.titleLabel.text ?? "")
                self.closeAct()
            }).disposed(by: disposeBag)
    }
    
    @objc func changed() {
        if let datePicker = self.getStackView.subviews.last as? UIDatePicker {
            let date = self.dateFormatting().string(from: datePicker.date)
            titleLabel.text = date
        } else {
            titleLabel.text = self.dateFormatting().string(from: Date())
        }
    }
    
    @IBAction func closeAct() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    private func dateFormatting() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
}
