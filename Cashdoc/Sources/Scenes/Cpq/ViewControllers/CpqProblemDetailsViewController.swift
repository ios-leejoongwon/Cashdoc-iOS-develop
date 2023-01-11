//
//  CpqProblemDetailsViewController.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import SafariServices
import SnapKit
import RxCocoa

protocol CpqProblemDetailsViewControllerDelegate: NSObjectProtocol {
    func serchTextCopyToast(_ viewController: CpqProblemDetailsViewController, text: String)
}

class CpqProblemDetailsViewController: CashdocViewController {
    
    // MARK: - NSLayoutConstraints
    private var quizSearchImageNaverButtonHeight: Constraint?
    private var searchButtonWidth: NSLayoutConstraint!
    
    // MARK: - Properties
    
    weak var delegate: CpqProblemDetailsViewControllerDelegate? 
    
    var cpqQuizModel: CpqQuizModel? {
        didSet {
            guard let cpqQuizModel = cpqQuizModel else {return}
            
            if let question = cpqQuizModel.quiz?.detail?.question {
                self.quizTextLabel.text = question
            }
            
            if let hint = cpqQuizModel.quiz?.detail?.hint {
                let hintString = " \(hint)"
                self.hintTextLabel.text = hintString
                self.hintTextLabel.isHidden = false
                self.hintCheckImageView.isHidden = false
                
                if let searchBtnText = cpqQuizModel.quiz?.detail?.searchBtnText {
                    if searchBtnText.count > 0 {
                        searchButton.setTitle(searchBtnText, for: .normal)
                        var fontSizeWidth = (searchBtnText as NSString).size(withAttributes: [NSAttributedString.Key.font: searchButton.titleLabel?.font as Any]).width
                        if fontSizeWidth > 220 {
                            fontSizeWidth = 220
                        }
                        searchButtonWidth.constant = fontSizeWidth + 30
                    }
                }
                
                if let keywordImageUrl = cpqQuizModel.quiz?.keywordImageUrl {
                    if keywordImageUrl.count > 0 {
                        
                        quizSearchImageNaverButton.isHidden = false
                        quizSearchImageNaverButton.kf.setImage(with: URL(string: keywordImageUrl), for: .normal)
                        quizSearchImageNaverButton.kf.setImage(with: URL(string: keywordImageUrl), for: .selected)
                        
                        guard let url = URL(string: keywordImageUrl) else {return}
                        guard let data = try? Data(contentsOf: url) else {return}
                        
                        guard let image = UIImage(data: data) else {return}
                        quizSearchImageNaverButtonHeight?.update(offset: self.getImageHeight(size: image.size))
                    }
                }
            }
        
            if let description = cpqQuizModel.quiz?.description {
                self.quizExplanationLabel.text = description
                self.quizExplanationLabel.sizeToFit()
                self.horizontalLine.isHidden = false
            }
        }
    }

    // MARK: - UI Components
    private var quizCheckImageView: UIImageView!
    private var quizTextLabel: UITextView!
    private var hintCheckImageView: UIImageView!
    private var quizSearchImageNaverButton: UIButton!
    private var hintTextLabel: UITextView!
    private var searchButton: UIButton!
    private var horizontalLine: UIView!

    private var quizExplanationLabel = UITextView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .blackCw
        $0.text = ""
        $0.isEditable = false
        $0.dataDetectorTypes = .link
        $0.isScrollEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setSelector()
    }

    // MARK: - Con(De)structor

    init() {
        super.init(nibName: nil, bundle: nil)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private selector

    private func getImageHeight(size: CGSize) -> CGFloat {
        let aspectRatio = size.height/size.width
        return ScreenSize.WIDTH*aspectRatio
    }

    private func setSelector() {
        searchButton.addTarget(self, action: #selector(didClickedsearchButton), for: .touchUpInside)
        quizSearchImageNaverButton.addTarget(self, action: #selector(didClickedQuizSearchImageNaverButton), for: .touchUpInside)
    }
    
    private func setupUI() {
        quizCheckImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = UIImage(named: "imgDetailQuiz")
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(view).offset(48)
                $0.leading.equalTo(view).offset(40)
                $0.width.equalTo(54)
                $0.height.equalTo(33)
            }
        }
        quizTextLabel = UITextView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .blackCw
            $0.text = ""
            $0.isEditable = false
            $0.dataDetectorTypes = .link
            $0.isScrollEnabled = false
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(quizCheckImageView.snp.bottom).offset(12)
                $0.leading.equalTo(view).offset(40)
                $0.trailing.equalTo(view).offset(-40)
            }
            
        }
        hintCheckImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = UIImage(named: "imgDetailHint")
            $0.isHidden = true
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(quizTextLabel.snp.bottom).offset(48)
                $0.leading.equalTo(view).offset(40)
                $0.width.equalTo(54)
                $0.height.equalTo(33)
            }
        }
        quizSearchImageNaverButton = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setTitle("", for: .normal)
            $0.isHidden = true
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(hintCheckImageView.snp.bottom).offset(12)
                $0.leading.trailing.equalTo(view)
                quizSearchImageNaverButtonHeight = $0.height.equalTo(0).constraint
            }
        }
        
        hintTextLabel = UITextView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .blackCw
            $0.text = ""
            $0.isEditable = false
            $0.dataDetectorTypes = .link
            $0.isScrollEnabled = false
            $0.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            $0.isHidden = true
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(quizSearchImageNaverButton.snp.bottom)
                $0.leading.equalTo(view).offset(48)
                $0.trailing.equalTo(view).offset(-48)
            }
        }
        
        searchButton = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setTitle("정답 찾으러 가기", for: .normal)
            $0.setTitleColor(.blackThreeCw, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            $0.setBackgroundColor(UIColor.fromRGB(255, 210, 0), forState: .normal)
            $0.setBackgroundColor(.sunFlowerYellowClickCw, forState: .highlighted)
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(hintTextLabel.snp.bottom).offset(16)
                $0.centerX.equalTo(view)
                $0.height.equalTo(40)
            }
            searchButtonWidth = $0.widthAnchor.constraint(equalToConstant: 180)
            searchButtonWidth.isActive = true
        }
        
        horizontalLine = UIView().then {
            $0.backgroundColor = .lineGrayCw
            $0.isHidden = true
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(searchButton.snp.bottom).offset(46)
                $0.leading.equalTo(view).offset(40)
                $0.trailing.equalTo(view).offset(-40)
                $0.height.equalTo(1).priority(.high)
            }
        }
        quizExplanationLabel = UITextView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .blackCw
            $0.text = ""
            $0.isEditable = false
            $0.dataDetectorTypes = .link
            $0.isScrollEnabled = false
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(horizontalLine.snp.bottom).offset(25)
                $0.leading.equalTo(view).offset(40)
                $0.trailing.equalTo(view).offset(-40)
                $0.bottom.equalToSuperview()
            }
        }
    }

    @objc private func didClickedsearchButton() {
        
        defer {
    //        AnalyticsManager.log(.quiz_landing)
        }
        
        guard let cpqQuizModel = cpqQuizModel else {return}
        
        if let keyword = cpqQuizModel.quiz?.keyword {
            if keyword.count > 0 {
                UIPasteboard.general.string = keyword
                delegate?.serchTextCopyToast(self, text: keyword)
            }
        }
        
        if let redirectUrl = cpqQuizModel.quiz?.detail?.redirectUrl {
            if redirectUrl.count > 0 {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                    LinkManager.open(type: .outLink, url: redirectUrl)
                })
            }
        }
    }

    @objc private func didClickedQuizSearchImageNaverButton() {
        guard let cpqQuizModel = cpqQuizModel, let keyword = cpqQuizModel.quiz?.keyword else {return}
        if keyword.count > 0 {
            UIPasteboard.general.string = keyword
            delegate?.serchTextCopyToast(self, text: keyword)
        }
    }
}
