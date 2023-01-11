//
//  InviteFriendViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import RxOptional
import RxGesture
import SnapKit
import Then

final class InviteFriendViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private let viewModel = InviteFriendViewModel()
    private var scrollViewHeight: Constraint?
    private var inviteInfoViewHeight: Constraint?
    
    // 추천캐시
    private var recommendPoint: Int = 0 {
        didSet {
            self.joinOneCashLabel.text = "\(recommendPoint)캐시"
            self.joinTenCashLabel.text = "\(recommendPoint * 10)캐시"
        }
    }
    
    // MARK: - UI Components
    private var scrollView: UIScrollView!
    private var containerView: UIView!
    private var inviteMainView: UIView!
    
    private var inviteMainImage: UIImageView!
    
    private var myRecommendCodeView: UIView!
    
    private var linkStackView: UIStackView!
    
    private var myCodeTitleLabel: UILabel!
    private var myCodeMiddleBar: UIImageView!
    private var myCodeValueLabel: UILabel!
    
    private var myCodeCopyImage: UIImageView!
    
    private var kakaoImage: UIImageView!
    private var linkCopyImage: UIImageView!
    private var moreImage: UIImageView!
    
    private var benefitsView: UIView!
    private var benefitsTitleLabel: UILabel!
    private var benefitsJoinOneView: UIView!
    private var joinOneTitleLabel: UILabel!
    private var joinOneCashLabel: UILabel!
    private var benefitsJoinTenView: UIView!
    private var joinTenTitleLabel: UILabel!
    private var joinTenCashLabel: UILabel!
    private var inviteStatusView: UIView!
    
    private var inviteStatusTitleLabel: UILabel!
    private var currentInviteStatusLabel: UILabel!
    private var untilInviteTenLabel: UILabel!
    private var inviteInfoView: UIView!
    private var informationUseView: UIView!
    private var informationUseTitleLabel: UILabel!
    private var inforStepOneTitleLabel: UILabel!
    private var infoStepOneContentsLabel: UILabel!
    private var inforStepTwoTitleLabel: UILabel!
    private var infoStepTwoContentsLabel: UILabel!
    private var noticeView: UIView!
    private var noticeTitleLabel: UILabel!
    private var noticeContentsLabel: UILabel!
    
    private var line: UIView!
    // MARK: - Con(De)structor
    
//    init() {
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         
    }
    
    // MARK: - Binding
    
    private func bindView() {
        UserManager.shared.user
            .bind { [weak self] (user) in
                guard let self = self else { return }
                self.myCodeValueLabel.text = user.code
            }
            .disposed(by: disposeBag)
        UserManager.shared.point
            .bind { [weak self] (point) in
                guard let self = self else { return }
                if let recommend = point.recommend {
                    self.recommendPoint = recommend
                }
            }
            .disposed(by: disposeBag)
        
        myRecommendCodeView
            .rx.tapGesture()
            .skip(1)
            .map {[weak self] _ in self?.myCodeValueLabel.text}
            .filterNil()
            .observe(on: MainScheduler.asyncInstance)
            .bind(onNext: { [weak self] (myCode) in
                guard let self = self else { return }
                UIPasteboard.general.string = myCode
                self.view.makeToastWithCenter("추천코드가 복사되었습니다.")
            })
            .disposed(by: disposeBag)
            
        kakaoImage.rx
            .tapGesture()
            .skip(1)
            .map {[weak self]_ in self?.myCodeValueLabel.text}
            .filterNil()
            .bind { [weak self] (myCode) in
                guard let self = self else { return }
                self.kakaoShare(myCode)
        }
        .disposed(by: disposeBag)
        
        linkCopyImage.rx
            .tapGesture()
            .skip(1)
            .map {[weak self] _ in self?.myCodeValueLabel.text}
            .filterNil()
            .bind { [weak self] (myCode) in
                guard let self = self else { return }
                self.linkCopyShare(myCode)
        }
        .disposed(by: disposeBag)
        
        moreImage.rx
            .tapGesture()
            .skip(1)
            .map {[weak self] _ in self?.myCodeValueLabel.text}
            .filterNil()
            .bind { [weak self] (myCode) in
                guard let self = self else { return }
                self.moreShare(myCode)
        }
        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        // Input
        Log.al("추천코드")
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).take(1).mapToVoid()
        
        let input = InviteFriendViewModel.Input(trigger: viewWillAppear.asDriverOnErrorJustNever())
        
        // Output 
        let output = viewModel.transform(input: input)
          
        output.sections
            .drive()
            .disposed(by: disposeBag)
        output.currentInviteCount
            .drive(onNext: { [weak self] (count) in
                guard let self = self else {return}
                Log.al("count = \(count)")
                let text = NSMutableAttributedString(string: "\(count)", attributes: [.font: UIFont.systemFont(ofSize: 24 * widthRatio, weight: .medium), .foregroundColor: UIColor.blueCw])
                text.append(NSAttributedString(string: "명", attributes: [.font: UIFont.systemFont(ofSize: 24 * widthRatio, weight: .regular), .foregroundColor: UIColor.black]))
                self.currentInviteStatusLabel.attributedText = text
                
                if count > 19 {
                    self.inviteInfoView.isHidden = false
                    self.inviteInfoViewHeight?.update(offset: 136)
                } else {
                    self.inviteInfoView.isHidden = true
                    self.inviteInfoViewHeight?.update(offset: 0)
                }
            }).disposed(by: disposeBag)
        
        output.recommendPoint
            .drive(onNext: { [weak self] (count) in
                self?.recommendPoint = count
                self?.joinOneCashLabel.text = count.commaValue + "캐시"
            }).disposed(by: disposeBag)
        
        output.recommendEvent
            .drive(onNext: { [weak self] (count) in
                self?.joinTenCashLabel.text = count.commaValue + "캐시"
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        title = "친구 초대"
    }
    
    private func setupView() {
        
        scrollView = UIScrollView().then {
            $0.showsVerticalScrollIndicator = false
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                m.right.left.equalToSuperview()
                m.width.equalToSuperview()
                scrollViewHeight = m.height.equalToSuperview().priority(750).constraint
            }
        }
         
        containerView = UIView().then {
            scrollView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.right.left.bottom.centerX.equalToSuperview()
            }
        }
          
        inviteMainView = UIView().then {
            $0.backgroundColor = .grayTwoCw
            containerView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.left.right.equalToSuperview()
            }
        }
        setupInviteMainView()
        
        benefitsView = UIView().then {
            containerView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.right.left.equalToSuperview()
                m.top.equalTo(inviteMainView.snp.bottom)
            }
        }
         
        setupBenefitsView()
        
        inviteStatusView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(benefitsView.snp.bottom)
                m.right.left.equalToSuperview()
            }
        }
        
        setupInviteStatusView()
        
        informationUseView = UIView().then {
            containerView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.right.left.equalToSuperview()
                m.top.equalTo(inviteStatusView.snp.bottom)
            }
        }
        
        noticeView = UIView().then {
            $0.backgroundColor = .grayTwoCw
            containerView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.right.left.bottom.equalToSuperview()
                m.top.equalTo(informationUseView.snp.bottom)
            }
        }
         
        setupInformationUseAndNoticeView()
        
    }
    
    private func setupInviteMainView() {
        inviteMainImage = UIImageView().then {
            $0.image = UIImage(named: "imgFriendAddBig")
            $0.contentMode = .scaleAspectFit
            inviteMainView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(44)
                m.left.right.equalToSuperview()
                m.width.equalToSuperview()
                m.height.equalTo(view.snp.width).multipliedBy(0.7653)
            
            }
        }
         
        myRecommendCodeView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .grayTwoCw
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.veryLightPinkCw.cgColor
            $0.layer.cornerRadius = 4
            inviteMainView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(inviteMainImage.snp.bottom).offset(8)
                m.right.left.equalToSuperview().inset(24)
            }
        }
        
        myCodeTitleLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.text = "내 추천 코드"
            myRecommendCodeView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(17)
                m.bottom.equalToSuperview().offset(-16)
                m.left.equalToSuperview().offset(24)
            }
            
        }
          
        myCodeMiddleBar = UIImageView().then {
            $0.backgroundColor = .grayCw
            myRecommendCodeView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(0.5)
                m.height.equalTo(21)
                m.centerY.equalTo(myCodeTitleLabel.snp.centerY)
                m.left.equalTo(myCodeTitleLabel.snp.right).offset(16)
            }
        }
           
        myCodeCopyImage = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = UIImage(named: "icCopy1Black")
            myRecommendCodeView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerY.equalTo(myCodeTitleLabel.snp.centerY)
                m.right.equalToSuperview().offset(-24)
                m.size.equalTo(18)
            }
        }
        
        myCodeValueLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToMedium(ofSize: 18)
            $0.textColor = .blackCw
            $0.textAlignment = .right
            myRecommendCodeView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerY.equalTo(myCodeTitleLabel.snp.centerY)
                m.right.equalTo(myCodeCopyImage.snp.left).offset(-8)
            }
        }
        
        linkStackView = UIStackView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.distribution = .equalSpacing
            $0.spacing = 40
            inviteMainView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(myRecommendCodeView.snp.bottom).offset(24)
                m.centerX.equalTo(myRecommendCodeView.snp.centerX)
                m.bottom.equalToSuperview().offset(-24)
            }
        }
        
        kakaoImage = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.toLinkImage(with: "icLogoKakaoBrown",
                           backgroundColor: .dandelionCw,
                           viewSize: 56,
                           imageSize: 32)
            linkStackView.addArrangedSubview($0)
        }
        
        linkCopyImage = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.toLinkImage(with: "icCopyWhite",
                           backgroundColor: .brownishGrayCw,
                           viewSize: 56,
                           imageSize: 32)
            linkStackView.addArrangedSubview($0)
        }
 
        moreImage = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.toLinkImage(with: "icMoreWhite",
                           backgroundColor: .grayCw,
                           viewSize: 56,
                           imageSize: 32)
            linkStackView.addArrangedSubview($0)
        }
    }
    
    private func setupBenefitsView() {
        benefitsTitleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToMedium(ofSize: 18)
            $0.textColor = .blackCw
            $0.text = "혜택"
            benefitsView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(32)
                m.left.equalToSuperview().offset(24)
            }
        }
          
        benefitsJoinOneView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.veryLightPinkCw.cgColor
            $0.layer.cornerRadius = 4
            benefitsView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.right.equalToSuperview().offset(-24)
                m.top.equalTo(benefitsTitleLabel.snp.bottom).offset(8)
                m.left.equalTo(benefitsTitleLabel.snp.left)
            }
            
        }
         
        benefitsJoinTenView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.veryLightPinkCw.cgColor
            $0.layer.cornerRadius = 4
            benefitsView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.bottom.equalToSuperview()
                m.top.equalTo(benefitsJoinOneView.snp.bottom).offset(8)
                m.left.equalTo(benefitsJoinOneView.snp.left)
                m.right.equalTo(benefitsJoinOneView.snp.right)
            }
        }
        
        joinOneTitleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.text = "친구 1명 가입할때마다"
            benefitsJoinOneView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(26)
                m.bottom.equalToSuperview().offset(-25)
                m.left.equalToSuperview().offset(16)
            }
        }
        
        joinOneCashLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToMedium(ofSize: 24)
            $0.textColor = .blueCw
            $0.textAlignment = .right
            $0.text = "\(recommendPoint)캐시"
            benefitsJoinOneView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(22)
                m.bottom.equalToSuperview().offset(-21)
                m.right.equalToSuperview().offset(-16)
            }
        }
         
        joinTenTitleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.text = "친구 10명\n가입할때마다 추가로"
            benefitsJoinTenView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(26)
                m.bottom.equalToSuperview().offset(-25)
                m.left.equalToSuperview().offset(16)
            }
        }
        
        joinTenCashLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToMedium(ofSize: 24)
            $0.textColor = .blueCw
            $0.textAlignment = .right
            $0.text = "\(recommendPoint * 10)캐시"
            benefitsJoinTenView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(22)
                m.bottom.equalToSuperview().offset(-21)
                m.right.equalToSuperview().offset(-16)
            }
        }
    }
    
    private func setupInviteStatusView() {
        inviteStatusTitleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToMedium(ofSize: 18)
            $0.textColor = .blackCw
            $0.text = "친구 초대 현황"
            inviteStatusView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(40)
                m.left.equalToSuperview().offset(24)
            }
        }
          
        currentInviteStatusLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToRegular(ofSize: 24)
            $0.textColor = .blackCw
            inviteStatusView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.right.equalToSuperview().offset(-24)
                m.lastBaseline.equalTo(inviteStatusTitleLabel.snp.lastBaseline)
                
            }
        }
        
        untilInviteTenLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToRegular(ofSize: 14)
            $0.text = "(최대 100명)"
            $0.textColor = .blackCw
            $0.textAlignment = .right
            inviteStatusView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(currentInviteStatusLabel.snp.bottom)
                m.right.equalTo(currentInviteStatusLabel.snp.right)
            }
        }
        
       line = UIView().then {
           $0.backgroundColor = .grayCw
           inviteStatusView.addSubview($0)
           $0.snp.makeConstraints { m in
               m.height.equalTo(1)
               m.left.right.equalToSuperview().inset(24)
               m.bottom.equalToSuperview()
           }
       }
       
        inviteInfoView = UIView().then {
            $0.backgroundColor = .grayThreeCw
            $0.IBborderColor = .grayCw
            $0.IBborderWidth = 0.5
            $0.IBcornerRadius = 4
            inviteStatusView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(inviteStatusTitleLabel.snp.bottom).offset(38)
                m.height.equalTo(136)
                m.right.left.equalToSuperview().inset(24)
                m.bottom.equalTo(line.snp.top).offset(-24)
                inviteInfoViewHeight = m.height.equalTo(136).constraint
            }
        }

        let Vstack = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 4
            inviteInfoView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.right.left.top.bottom.equalToSuperview().inset(16)
            }
        }

        _ = UILabel().then {
            $0.text = "친구를 20명 넘게 초대했어요."
            $0.textColor = .blackCw
            $0.setFontToBold(ofSize: 14)
            Vstack.addArrangedSubview($0)
        }

        _ = UILabel().then {
            $0.text = "내 추천코드와 친구의 추천코드를\ncs@cashdoc.me로 보내주세요. 친구의 신규\n가입일 포함 3일 이내에 cs센터 메일로 보내주시면 적\n립을 안내해 드리겠습니다."
            $0.numberOfLines = 0
            $0.textColor = .brownishGray
            $0.setFontToMedium(ofSize: 14)
            let font = UIFont.systemFont(ofSize: 14, weight: .bold)
            let attributedStr = NSMutableAttributedString(string: $0.text!)
            attributedStr.addAttribute(NSAttributedString.Key.font, value: font, range: ($0.text! as NSString).range(of: "cs@cashdoc.me"))
            $0.attributedText = attributedStr
            Vstack.addArrangedSubview($0)
        }

    }
    
    private func setupInformationUseAndNoticeView() {
        informationUseTitleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToMedium(ofSize: 18)
            $0.textColor = .blackCw
            $0.text = "이용안내"
            informationUseView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.left.equalToSuperview().offset(24)
            }
        }
         
        inforStepOneTitleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = .blackCw
            $0.text = "Step 01"
            informationUseView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(informationUseTitleLabel.snp.bottom).offset(12)
                m.left.equalTo(informationUseTitleLabel.snp.left)
            }
        }
        
        infoStepOneContentsLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.text = "친구에게 캐시닥 초대 링크를 공유합니다."
            informationUseView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(inforStepOneTitleLabel.snp.bottom).offset(4)
                m.left.equalTo(inforStepOneTitleLabel.snp.left)
            }
        }
         
        inforStepTwoTitleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = .blackCw
            $0.text = "Step 02"
            informationUseView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(infoStepOneContentsLabel.snp.bottom).offset(12)
                m.left.equalTo(infoStepOneContentsLabel.snp.left)
            }
        }
        
        infoStepTwoContentsLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.numberOfLines = 2
            $0.text = "공유한 링크를 통해 친구가 캐시닥 회원가입 시 회원님의 추천인 코드를 입력합니다."
            informationUseView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(inforStepTwoTitleLabel.snp.bottom).offset(4)
                m.left.equalTo(inforStepTwoTitleLabel.snp.left)
                m.right.equalToSuperview().offset(-24)
                m.bottom.equalToSuperview().offset(-40)
            }
        }
            
        noticeTitleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = .blackCw
            $0.text = "알림"
            noticeView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.left.equalToSuperview().offset(24)
            }
        }
        
        noticeContentsLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.numberOfLines = 0
            $0.text = "- 정상적인 링크를 통해 추천 코드를 받아 가입하신 분만\n적립 가능합니다.\n- 신규 가입자만 측정됩니다.\n- 본 이벤트는 사전 예고 없이 조기 종료되거나 변경 및 \n취소될 수 있습니다.\n- 부적절한 방법으로 캐시를 적립한 회원은 캐시 적립이\n취소됩니다."
            noticeView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.right.bottom.equalToSuperview().offset(-24)
                m.top.equalTo(noticeTitleLabel.snp.bottom).offset(9)
                m.left.equalTo(noticeTitleLabel.snp.left)
            }
        }
         
    }
    
    private func kakaoShare(_ myCode: String) {
        GlobalFunction.shareKakao("100% 당첨되는 행운룰렛에서 10,000 캐시를 뽑아보세요", description: "지금 가입 시 바로 지급됩니다.", imgURL: API.LINK_IMG_URL, buttonTitle: "추천코드 \(myCode)")
    }
    
    private func linkCopyShare(_ myCode: String) {
        let text = """
        추천코드 입력하고 \(recommendPoint.commaValue)캐시 받자!\n
        추천코드 : \(myCode)
        
        확인만 해도 돈이 되는 자동 가계부 캐시닥을 설치하고 간편한 내 돈 관리 시작해 보세요!
        
        \(API.WEB_CASHDOC_URL)
        """
        UIPasteboard.general.string = text
        self.view.makeToastWithCenter("링크가 복사되었습니다.")
    }
    
    private func moreShare(_ myCode: String) {
        let text = """
        추천코드 입력하고 \(recommendPoint.commaValue)캐시 받자!\n
        추천코드 : \(myCode)
        
        확인만 해도 돈이 되는 자동 가계부 캐시닥을 설치하고 간편한 내 돈 관리 시작해 보세요!
        
        \(API.WEB_CASHDOC_URL)
        """
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityVC.excludedActivityTypes = [.airDrop]
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
