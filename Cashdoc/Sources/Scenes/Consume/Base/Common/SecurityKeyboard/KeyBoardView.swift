//
//  KeyBoardView.swift
//  SecurityKeyboard
//
//  Created by Sangbeom Han on 20/09/2019.
//  Copyright © 2019 Sangbeom Han. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

class KeyBoardView: UIView {
    
    // MARK: - UI Components
    
    private let verticalStack = UIStackView()
    private let shuffleButton = KeyButton()
    private let specialCharButton = KeyButton()
    private let spaceButton = KeyButton()
    private let confirmButton = KeyButton()
    private let shiftButton = KeyButton()
    private let deleteButton = KeyButton()
    
    private let emptyButton1_1 = KeyButton()
    private let emptyButton2_1 = KeyButton()
    private let emptyButton3_1 = KeyButton()
    private let emptyButton3_2 = KeyButton()
    private let emptyButton4_1 = KeyButton()
    private let emptyButton4_2 = KeyButton()
    
    // MARK: - Properties
    
    weak var target: UITextField?
    
    private let disposeBag = DisposeBag()
    
    private var width: CGFloat!
    private var height: CGFloat!
    
    private var shifted = false
    private var specialChar = false
    
    private let normalTextSetList = [
        [ ("1", ""), ("2", ""), ("3", ""), ("4", ""), ("5", ""), ("6", ""), ("7", ""), ("8", ""), ("9", ""), ("0", "") ], // 10
        [ ("q", "ㅂ"), ("w", "ㅈ"), ("e", "ㄷ"), ("r", "ㄱ"), ("t", "ㅅ"), ("y", "ㅛ"), ("u", "ㅕ"), ("i", "ㅑ"), ("o", "ㅐ"), ("p", "ㅔ") ], // 10
        [ ("a", "ㅁ"), ("s", "ㄴ"), ("d", "ㅇ"), ("f", "ㄹ"), ("g", "ㅎ"), ("h", "ㅗ"), ("j", "ㅓ"), ("k", "ㅏ"), ("l", "ㅣ") ], // 9
        [ ("z", "ㅋ"), ("x", "ㅌ"), ("c", "ㅊ"), ("v", "ㅍ"), ("b", "ㅠ"), ("n", "ㅜ"), ("m", "ㅡ") ] // 7 + 2
    ]
    private let shiftedTextSetList = [
        [ ("!", ""), ("@", ""), ("#", ""), ("$", ""), ("%", ""), ("^", ""), ("&", ""), ("*", ""), ("(", ""), (")", "") ],
        [ ("Q", "ㅃ"), ("W", "ㅉ"), ("E", "ㄸ"), ("R", "ㄲ"), ("T", "ㅆ"), ("Y", "ㅛ"), ("U", "ㅕ"), ("I", "ㅑ"), ("O", "ㅒ"), ("P", "ㅖ") ],
        [ ("A", "ㅁ"), ("S", "ㄴ"), ("D", "ㅇ"), ("F", "ㄹ"), ("G", "ㅎ"), ("H", "ㅗ"), ("J", "ㅓ"), ("K", "ㅏ"), ("L", "ㅣ") ],
        [ ("Z", "ㅋ"), ("X", "ㅌ"), ("C", "ㅊ"), ("V", "ㅍ"), ("B", "ㅠ"), ("N", "ㅜ"), ("M", "ㅡ") ]
    ]
    private let specialTextSetList = [
        [ ("!", ""), ("@", ""), ("#", ""), ("$", ""), ("%", ""), ("^", ""), ("&", ""), ("*", ""), ("(", ""), (")", "") ],
        [ ("`", ""), ("-", ""), ("=", ""), ("₩", ""), ("[", ""), ("]", ""), (";", ""), ("'", ""), (",", ""), (".", "") ],
        [ ("/", ""), ("~", ""), ("_", ""), ("+", ""), ("|", ""), ("{", ""), ("}", ""), (":", ""), ("\"", "") ],
        [ ("", ""), ("", ""), ("<", ""), (">", ""), ("?", ""), ("", ""), ("", "") ]
    ]
    
    // MARK: - Con(De)structor
    
    init(target: UITextField) {
        self.target = target
        super.init(frame: .zero)
        
        addSubview(verticalStack)
        addSubview(emptyButton1_1)
        
        layout()
        
        bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubview(verticalStack)
        addSubview(emptyButton1_1)
        layout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        width = frame.size.width
        height = frame.size.height
        
        addSubview(verticalStack)
        addSubview(emptyButton1_1)
        
        layout()
        
        bindViewModel()
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        shuffleButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let self = self else { return }
            self.shuffleEmptyButton()
        }).disposed(by: disposeBag)
        
        shiftButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let self = self else { return }
            self.shiftButtonTapped()
        }).disposed(by: disposeBag)
        
        specialCharButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let self = self else { return }
            self.specialCharButtonTapped()
        }).disposed(by: disposeBag)
        
        deleteButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let self = self else { return }
            self.target?.deleteBackward()
        }).disposed(by: disposeBag)
        
        confirmButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let self = self else { return }
            guard let target = self.target else { return }
            target.sendActions(for: .editingDidEndOnExit)
            }).disposed(by: disposeBag)
        
        spaceButton.rx.tap.subscribe(onNext: { [weak self] (_) in
            guard let self = self else { return }
            guard let target = self.target,
                let text = target.text,
                text.count > 0 else { return }
            self.target?.insertText(" ")
        }).disposed(by: disposeBag)
    }
    
    // MARK: - Layout
    
    private func layout() {
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        backgroundColor = .black
        
        verticalStack.axis = .vertical
        verticalStack.alignment = .fill
        verticalStack.distribution = .fillEqually
        verticalStack.spacing = 0
        verticalStack.backgroundColor = .orange
        verticalStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        var bottomMargin = CGFloat(-8.0)
        
        if UIDevice.current.userInterfaceIdiom == .phone &&
            UIScreen.main.nativeBounds.height < 1500 {
            bottomMargin = 0
        }
        verticalStack.translatesAutoresizingMaskIntoConstraints = false
        verticalStack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        verticalStack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        verticalStack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        verticalStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomMargin).isActive = true
        
        for i in 0 ..< normalTextSetList.count {
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.alignment = .fill
            horizontalStack.distribution = .fillProportionally
            horizontalStack.spacing = 0
            horizontalStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            switch i {
            case 3:
                shiftButton.setTitle("↑", for: .normal)
                shiftButton.setTitleColor(.white, for: .normal)
                shiftButton.setBackgroundColor(.black, forState: .normal)
                shiftButton.setBackgroundColor(.gray, forState: .highlighted)
                shiftButton.width = 2
                horizontalStack.addArrangedSubview(shiftButton)
                horizontalStack.setNeedsLayout()
            default:
                break
            }
            
            for j in 0 ..< normalTextSetList[i].count {
                let button = KeyButton()

                initButton(button: button, row: i, column: j)
                
                horizontalStack.addArrangedSubview(button)
            }
            
            switch i {
            case 0:
                let randomNumber = Int.random(in: 1 ..< normalTextSetList[i].count)
                emptyButton1_1.backgroundColor = .black
                emptyButton1_1.width = 2
                horizontalStack.insertArrangedSubview(emptyButton1_1, at: randomNumber)
                horizontalStack.setNeedsLayout()
            case 1:
                let randomNumber = Int.random(in: 0 ..< normalTextSetList[i].count)
                emptyButton2_1.backgroundColor = .black
                emptyButton2_1.width = 2
                horizontalStack.insertArrangedSubview(emptyButton2_1, at: randomNumber)
                horizontalStack.setNeedsLayout()
            case 2:
                var randomNumber = Int.random(in: 0 ..< normalTextSetList[i].count - 1)
                emptyButton3_1.backgroundColor = .black
                emptyButton3_1.width = 2
                horizontalStack.insertArrangedSubview(emptyButton3_1, at: randomNumber)
                randomNumber = Int.random(in: randomNumber ..< normalTextSetList[i].count)
                emptyButton3_2.backgroundColor = .black
                emptyButton3_2.width = 2
                horizontalStack.insertArrangedSubview(emptyButton3_2, at: randomNumber)
                horizontalStack.setNeedsLayout()
            case 3:
                var randomNumber = Int.random(in: 1 ..< normalTextSetList[i].count - 1)
                emptyButton4_1.backgroundColor = .black
                emptyButton4_1.width = 2
                horizontalStack.insertArrangedSubview(emptyButton4_1, at: randomNumber)
                randomNumber = Int.random(in: randomNumber ..< normalTextSetList[i].count)
                emptyButton4_2.backgroundColor = .black
                emptyButton4_2.width = 2
                horizontalStack.insertArrangedSubview(emptyButton4_2, at: randomNumber)
                horizontalStack.setNeedsLayout()
                
                deleteButton.setTitle("⌫", for: .normal)
                deleteButton.setTitleColor(.white, for: .normal)
                deleteButton.setBackgroundColor(.black, forState: .normal)
                deleteButton.setBackgroundColor(.gray, forState: .highlighted)
                deleteButton.width = 2
                horizontalStack.addArrangedSubview(deleteButton)
                horizontalStack.setNeedsLayout()
            default:
                break
            }

            addSubview(horizontalStack)
            verticalStack.addArrangedSubview(horizontalStack)
        }
        
        let bottomHorizontalStack = UIStackView()
        bottomHorizontalStack.axis = .horizontal
        bottomHorizontalStack.alignment = .fill
        bottomHorizontalStack.distribution = .fillProportionally
        bottomHorizontalStack.spacing = 0
        bottomHorizontalStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        shuffleButton.setTitle("재배열", for: .normal)
        shuffleButton.setTitleColor(.white, for: .normal)
        shuffleButton.setBackgroundColor(.black, forState: .normal)
        shuffleButton.setBackgroundColor(.gray, forState: .highlighted)
        shuffleButton.width = 2
        bottomHorizontalStack.addArrangedSubview(shuffleButton)
        
        specialCharButton.setTitle("?#%", for: .normal)
        specialCharButton.setTitleColor(.white, for: .normal)
        specialCharButton.setBackgroundColor(.black, forState: .normal)
        specialCharButton.setBackgroundColor(.gray, forState: .highlighted)
        specialCharButton.width = 2
        bottomHorizontalStack.addArrangedSubview(specialCharButton)
        
        spaceButton.setTitle("SPACE", for: .normal)
        spaceButton.setTitleColor(.white, for: .normal)
        spaceButton.setBackgroundColor(.black, forState: .normal)
        spaceButton.setBackgroundColor(.gray, forState: .highlighted)
        spaceButton.width = 3
        bottomHorizontalStack.addArrangedSubview(spaceButton)

        confirmButton.setTitle("확인", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.setBackgroundColor(.black, forState: .normal)
        confirmButton.setBackgroundColor(.gray, forState: .highlighted)
        confirmButton.width = 2
        bottomHorizontalStack.addArrangedSubview(confirmButton)
        
        verticalStack.addArrangedSubview(bottomHorizontalStack)
    }
    
    private func initButton(button: KeyButton, row: Int, column: Int) {
        button.setBackgroundColor(.black, forState: .normal)
        button.setBackgroundColor(.gray, forState: .highlighted)
        
        button.specialText = specialTextSetList[row][column]
        button.shiftedText = shiftedTextSetList[row][column]
        button.normalText = normalTextSetList[row][column]

        button.tappedString.subscribe(onNext: { result in
            self.target?.insertText(result)
        }).disposed(by: disposeBag)
        
    }
    
    private func shiftButtonTapped() {
        
        for i in 0 ..< 4 {
            
            if let horizontalStack = verticalStack.arrangedSubviews[i] as? UIStackView {
                
                for j in 0 ..< horizontalStack.arrangedSubviews.count {
                    
                    if i == 3 && (j == 0 || j == horizontalStack.arrangedSubviews.count - 1) {
                        continue
                    }

                    if let button = horizontalStack.arrangedSubviews[j] as? KeyButton {
                        button.showShiftedText()
                    }
                }
            }
        }
    }
    
    private func specialCharButtonTapped() {
        
        for i in 0 ..< 4 {
            
            if let horizontalStack = verticalStack.arrangedSubviews[i] as? UIStackView {
                
                for j in 0 ..< horizontalStack.arrangedSubviews.count {
                    
                    if i == 3 && (j == 0 || j == horizontalStack.arrangedSubviews.count - 1) {
                        continue
                    }
                        
                    if let button = horizontalStack.arrangedSubviews[j] as? KeyButton {
                        button.showSpecialText()
                    }
                }
            }
        }
        shuffleEmptyButton()
    }
    
    private func shuffleEmptyButton() {
        for i in 0 ..< 4 {
            
            if let horizontalStack = verticalStack.arrangedSubviews[i] as? UIStackView {
                
                switch i {
                case 0:
                    horizontalStack.removeArrangedSubview(emptyButton1_1)
                    horizontalStack.setNeedsLayout()
                    horizontalStack.layoutIfNeeded()

                    let startRange = 0
                    let endRange = horizontalStack.arrangedSubviews.count
                    let randomNumber = Int.random(in: startRange ..< endRange)
                    horizontalStack.insertArrangedSubview(emptyButton1_1, at: randomNumber)
                    horizontalStack.setNeedsLayout()
                case 1:
                    horizontalStack.removeArrangedSubview(emptyButton2_1)
                    horizontalStack.setNeedsLayout()
                    horizontalStack.layoutIfNeeded()

                    let startRange = 0
                    let endRange = horizontalStack.arrangedSubviews.count
                    let randomNumber = Int.random(in: startRange ..< endRange)
                    horizontalStack.insertArrangedSubview(emptyButton2_1, at: randomNumber)
                    horizontalStack.setNeedsLayout()
                case 2:
                    horizontalStack.removeArrangedSubview(emptyButton3_1)
                    horizontalStack.setNeedsLayout()
                    horizontalStack.layoutIfNeeded()

                    let startRange = 0
                    let endRange = horizontalStack.arrangedSubviews.count
                    var randomNumber = Int.random(in: startRange ..< endRange)
                    horizontalStack.insertArrangedSubview(emptyButton3_1, at: randomNumber)
                    horizontalStack.setNeedsLayout()
                    
                    horizontalStack.removeArrangedSubview(emptyButton3_2)
                    horizontalStack.setNeedsLayout()
                    horizontalStack.layoutIfNeeded()

                    randomNumber = Int.random(in: startRange ..< endRange)
                    horizontalStack.insertArrangedSubview(emptyButton3_2, at: randomNumber)
                    horizontalStack.setNeedsLayout()
                case 3:
                    horizontalStack.removeArrangedSubview(emptyButton4_1)
                    horizontalStack.setNeedsLayout()
                    horizontalStack.layoutIfNeeded()

                    let startRange = 1
                    let endRange = horizontalStack.arrangedSubviews.count - 1
                    var randomNumber = Int.random(in: startRange ..< endRange)
                    horizontalStack.insertArrangedSubview(emptyButton4_1, at: randomNumber)
                    horizontalStack.setNeedsLayout()
                    
                    horizontalStack.removeArrangedSubview(emptyButton4_2)
                    horizontalStack.setNeedsLayout()
                    horizontalStack.layoutIfNeeded()

                    randomNumber = Int.random(in: startRange ..< endRange)
                    horizontalStack.insertArrangedSubview(emptyButton4_2, at: randomNumber)
                    horizontalStack.setNeedsLayout()
                default:
                    break
                }
            }
        }
            
    }
}
