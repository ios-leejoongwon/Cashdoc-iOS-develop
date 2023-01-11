//
//  TemplateScrollView.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/26.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift
import RxCocoa
import UIKit

final class TemplateScrollView: UIView {
    
    private(set) var selecteViewX: Constraint?
    
    // MARK: - Properties
    private var templateScrollView: UIScrollView!
    private var templateContentsView: UIStackView!
    
    private var template1Button: UIButton!
    private var template2Button: UIButton!
    private var template3Button: UIButton!
    private var template4Button: UIButton!
    private var template5Button: UIButton!
    private var template6Button: UIButton!
    private var template7Button: UIButton!
    private var template8Button: UIButton!
    private var template9Button: UIButton!
    private var template10Button: UIButton!
    private var template11Button: UIButton!
    
    private var selecteView: UIView!
    private var selecteTemplateImageView: UIImageView!
    
    let selecteTemplateType: BehaviorRelay<Int> = .init(value: 1)
    private var isGalleryTap: Bool? = false
    
    private var disposeBag = DisposeBag()
    // MARK: - Con(De)structor
    
    convenience init(isGalleryTap: Bool? = false) {
        self.init(frame: .zero)
        
        self.isGalleryTap = isGalleryTap
        
        templateScrollView = UIScrollView().then {
            self.addSubview($0)
            $0.isScrollEnabled = true
            $0.isUserInteractionEnabled = true
            $0.snp.makeConstraints {
                $0.trailing.equalToSuperview()
                $0.leading.equalToSuperview().offset(8)
                $0.centerY.equalToSuperview()
                $0.height.equalTo(76)
            }
        }
        templateContentsView = UIStackView().then {
            templateScrollView.addSubview($0)
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.alignment = .center
            $0.spacing = 7
//            $0.layoutMargins.left = 8.0
//            $0.layoutMargins.right = 8.0
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.edges.equalToSuperview()
            }
        }
        // 템플릿 순서 변경 주의 !! (1,2,3,10,11,9,8,7,5,4,6)
        template1Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template01"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalToSuperview()
                $0.size.equalTo(60)
            }
        }
        template2Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template02"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(template1Button.snp.trailing).offset(6)
                $0.size.equalTo(60)
            }
        }
        template3Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template03"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(template2Button.snp.trailing).offset(6)
                $0.size.equalTo(60)
            }
        }
        template4Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template04"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(template3Button.snp.trailing).offset(6)
                $0.size.equalTo(60)
            }
        }
        template5Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template05"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(template4Button.snp.trailing).offset(6)
                $0.size.equalTo(60)
            }
        }
        template6Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template06"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(template5Button.snp.trailing).offset(6)
                $0.size.equalTo(60)
            }
        }
        template7Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template07"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(template6Button.snp.trailing).offset(6)
                $0.size.equalTo(60)
            }
        }
        template8Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template08"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(template7Button.snp.trailing).offset(6)
                $0.size.equalTo(60)
            }
        }
        template9Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template09"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(template8Button.snp.trailing).offset(6)
                $0.size.equalTo(60)
            }
        }
        template10Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template10"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(template9Button.snp.trailing).offset(6)
                $0.size.equalTo(60)
            }
        }
        template11Button = UIButton().then {
            templateContentsView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "template11"), for: .normal)
            $0.snp.makeConstraints {
                $0.leading.equalTo(template10Button.snp.trailing).offset(6)
                $0.size.equalTo(60)
            }
        }
        selecteView = UIView().then {
            templateContentsView.addSubview($0)
            $0.backgroundColor = .white
            $0.alpha = 0.9
            $0.snp.makeConstraints {
                $0.centerY.equalTo(template1Button)
                selecteViewX = $0.leading.equalTo(template1Button.snp.leading).constraint
                $0.size.equalTo(60)
            }
        }
        selecteTemplateImageView = UIImageView().then {
            selecteView.addSubview($0)
            $0.image = UIImage(named: "icSelectionControlCheck")
            $0.contentMode = .scaleAspectFill
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.size.equalTo(32)
            }
        }
        bindView()
    }
    
    // MARK: - Binding
    private func bindView() {
        template1Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(1)
            })
            .disposed(by: disposeBag)
        template2Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(2)
            })
            .disposed(by: disposeBag)
        template3Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(3)
            })
            .disposed(by: disposeBag)
        template4Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(4)
            })
            .disposed(by: disposeBag)
        template5Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(5)
            })
            .disposed(by: disposeBag)
        template6Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(6)
            })
            .disposed(by: disposeBag)
        template7Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(7)
            })
            .disposed(by: disposeBag)
        template8Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(8)
            })
            .disposed(by: disposeBag)
        template9Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(9)
            })
            .disposed(by: disposeBag)
        template10Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(10)
            })
            .disposed(by: disposeBag)
        template11Button.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                self.selecteTemplateType.accept(11)
            })
            .disposed(by: disposeBag)
        
    }
    
    func selecteTemplate(type: Int) {
        var x: CGFloat = 0.0
        switch type {
        case 1:
            x = self.template1Button.frame.origin.x
        case 2:
            x = self.template2Button.frame.origin.x
        case 3:
            x = self.template3Button.frame.origin.x
        case 4:
            x = self.template4Button.frame.origin.x
        case 5:
            x = self.template5Button.frame.origin.x
        case 6:
            x = self.template6Button.frame.origin.x
        case 7:
            x = self.template7Button.frame.origin.x
        case 8:
            x = self.template8Button.frame.origin.x
        case 9:
            x = self.template9Button.frame.origin.x
        case 10:
            x = self.template10Button.frame.origin.x
        case 11:
            x = self.template11Button.frame.origin.x
        default:
            x = self.template1Button.frame.origin.x
        }
        self.selecteViewX?.update(offset: x)
    }
}
