//
//  MoreViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 22/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SmartAIB
import Kingfisher
import RxCocoa
import RxSwift

final class MoreViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var viewModel: MoreViewModel!
    
    private let provider = CashdocProvider<CertService>()
    private var items = SettingType.allCases
    private var numberOfSections: Int {
        return items.count
    }
    private var itemIndexPath = PublishRelay<(IndexPath, [SettingType])>()
    private var moreScrollViewHeight: NSLayoutConstraint!
    private var isShowRecommend: Bool = false
    
    // MARK: - UI Components
    
    private let moreScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    private let moreContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    private let profileView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    private let profileButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        return button
    }()
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "imgPlaceholderProfile")
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToMedium(ofSize: 16)
        label.textColor = .blackCw
        label.text = ""
        return label
    }()
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 12)
        label.textColor = .brownishGrayCw
        label.text = ""
        return label
    }()
    private let myRecommenCodeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.grayCw.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 11, bottom: 5, right: 11)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(.blackCw, for: .normal)
        button.setTitle("", for: .normal)
        return button
    }()
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icArrow01StyleRightGray")
        return imageView
    }()
    private let separateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .grayTwoCw
        return view
    }()
    private let buttonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    private let couponButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let couponImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icCouponBlack")
        return imageView
    }()
    private let couponTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.text = "쿠폰함"
        return label
    }()
    private let couponBadge: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.backgroundColor = .redCw
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        label.isHidden = true
        label.textAlignment = .center
        label.setFontToBold(ofSize: 11)
        return label
    }()
    private let cashButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let cashImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icSpendBlack")
        return imageView
    }()
    private let cashTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        label.text = "캐시"
        return label
    }()
    private let inviteFriendButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let inviteFriendImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "icFriendInvitedBlack")
        return imageView
    }()
    private let inviteFriendTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setFontToRegular(ofSize: 14)
        return label
    }()
    private let separateView01: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .grayCw
        return view
    }()
    private let separateView02: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .grayCw
        return view
    }()
    private let moreTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(cellType: MoreMenuTableViewCell.self)
        tableView.rowHeight = 64
        if #available(iOS 15, *) {
            tableView.sectionHeaderTopPadding = 1
        }
        tableView.sectionHeaderHeight = 32
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindView()
        bindViewModel()
        view.addSubview(moreScrollView)
        moreScrollView.addSubview(moreContentView)
        moreContentView.addSubview(profileView)
        profileView.addSubview(profileImageView)
        profileView.addSubview(nameLabel)
        profileView.addSubview(emailLabel)
        profileView.addSubview(arrowImageView)
        profileView.addSubview(profileButton)
        profileView.addSubview(myRecommenCodeButton)
        moreContentView.addSubview(separateView)
        moreContentView.addSubview(buttonView)
        buttonView.addSubview(couponButton)
        couponButton.addSubview(couponImageView)
        couponButton.addSubview(couponTitleLabel)
        couponButton.addSubview(couponBadge)
        buttonView.addSubview(cashButton)
        cashButton.addSubview(cashImageView)
        cashButton.addSubview(cashTitleLabel)
        buttonView.addSubview(inviteFriendButton)
        inviteFriendButton.addSubview(inviteFriendImageView)
        inviteFriendButton.addSubview(inviteFriendTitleLabel)
        buttonView.addSubview(separateView01)
        buttonView.addSubview(separateView02)
        moreContentView.addSubview(moreTableView)
        layout()
        showRecommend()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moreTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }    
    // MARK: - Binding
    
    private func bindView() {
        myRecommenCodeButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let pasteboard = UIPasteboard.general
                pasteboard.string = self.myRecommenCodeButton.titleLabel?.text?.replace(target: "내 추천코드 : ", withString: "")
                self.view.makeToastWithCenter("내 추천 코드가 복사되었습니다.", duration: 2.0, completion: nil)
            })
        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        // Input
        let viewWillAppearTrigger = self.rx.sentMessage(#selector(viewWillAppear(_:))).mapToVoid().asDriverOnErrorJustNever()
        
        let input = type(of: self.viewModel).Input(trigger: viewWillAppearTrigger,
                                              profileTrigger: profileButton.rx.tap.asDriver(),
                                              couponTrigger: couponButton.rx.tap.asDriver(),
                                              cashTrigger: cashButton.rx.tap.asDriver(),
                                              inviteFriendTrigger: inviteFriendButton.rx.tap.asDriverOnErrorJustNever().map {self.isShowRecommend},
                                              selection: itemIndexPath.asDriverOnErrorJustNever())
        // Output
        _ = viewModel.transform(input: input)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        let navigator = MoreNavigator(navigationController: GlobalDefine.shared.curNav ?? UINavigationController(),
                                      parentViewController: self)
        
        self.viewModel = MoreViewModel(navigator: navigator)
        
        self.title = "더보기"
        self.view.backgroundColor = .white
        moreTableView.delegate = self
        moreTableView.dataSource = self
        moreTableView.separatorStyle = .none
        UserManager.shared.user
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                self.cashTitleLabel.text = String(user.point ?? 0).convertToDecimal("캐시")
                if user.nickname.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.nameLabel.text = "닉네임을 입력해주세요"
                } else {
                    self.nameLabel.text = user.nickname
                }
                
                self.emailLabel.text = user.email
                self.myRecommenCodeButton.setTitle("내 추천코드 : \(user.code)", for: .normal)
                if let urlString = user.profileUrl {
                    Log.al("urlString = \(urlString)")
                    if let url = URL(string: urlString) {
                        self.profileImageView.kf.setImage(with: url)
                    } else {
                    }
                    
                } else {
                    self.profileImageView.image = UIImage(named: "imgPlaceholderProfile")
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func showRecommend() {
        isShowRecommend = UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue)
        if isShowRecommend {
            inviteFriendTitleLabel.text = "친구초대"
        } else {
            inviteFriendTitleLabel.text = "계정 정보"
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension MoreViewController: UITextFieldDelegate {
    
}

// MARK: - Layout

extension MoreViewController {
    
    private func layout() {
        moreScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        moreScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        moreScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive  = true
        moreScrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        moreScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        moreScrollViewHeight = moreScrollView.heightAnchor.constraint(equalTo: view.heightAnchor)
//        moreScrollViewHeight.priority = .init(750)
        moreScrollViewHeight.isActive = true
        
        moreContentView.topAnchor.constraint(equalTo: moreScrollView.topAnchor).isActive = true
        moreContentView.leadingAnchor.constraint(equalTo: moreScrollView.leadingAnchor).isActive = true
        moreContentView.trailingAnchor.constraint(equalTo: moreScrollView.trailingAnchor).isActive = true
        moreContentView.bottomAnchor.constraint(equalTo: moreScrollView.bottomAnchor).isActive = true
        moreContentView.centerXAnchor.constraint(equalTo: moreScrollView.centerXAnchor).isActive = true
        
        profileView.topAnchor.constraint(equalTo: moreContentView.topAnchor).isActive = true
        profileView.leadingAnchor.constraint(equalTo: moreContentView.leadingAnchor).isActive = true
        profileView.trailingAnchor.constraint(equalTo: moreContentView.trailingAnchor).isActive = true
        profileView.heightAnchor.constraint(equalToConstant: 132).isActive = true
        
        profileImageView.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 25).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: profileView.leadingAnchor, constant: 24).isActive = true
        profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12).isActive = true
        
        if let email = self.emailLabel.text, !email.isEmpty {
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2).isActive = true
            emailLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12).isActive = true
        } else {
            nameLabel.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor).isActive = true
        }
        
        arrowImageView.topAnchor.constraint(equalTo: profileView.topAnchor, constant: 33).isActive = true
        arrowImageView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 16).isActive = true
        arrowImageView.trailingAnchor.constraint(equalTo: profileView.trailingAnchor, constant: -24).isActive = true
        arrowImageView.widthAnchor.constraint(equalTo: arrowImageView.heightAnchor).isActive = true
        arrowImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        profileButton.topAnchor.constraint(equalTo: profileView.topAnchor).isActive = true
        profileButton.leadingAnchor.constraint(equalTo: profileView.leadingAnchor).isActive = true
        profileButton.trailingAnchor.constraint(equalTo: profileView.trailingAnchor).isActive = true
        profileButton.bottomAnchor.constraint(equalTo: profileView.bottomAnchor).isActive = true
        
        myRecommenCodeButton.bottomAnchor.constraint(equalTo: profileView.bottomAnchor, constant: -24).isActive = true
        myRecommenCodeButton.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        myRecommenCodeButton.trailingAnchor.constraint(lessThanOrEqualTo: profileView.trailingAnchor, constant: -16).isActive = true
        myRecommenCodeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        separateView.topAnchor.constraint(equalTo: profileView.bottomAnchor).isActive = true
        separateView.leadingAnchor.constraint(equalTo: moreContentView.leadingAnchor).isActive = true
        separateView.trailingAnchor.constraint(equalTo: moreContentView.trailingAnchor).isActive = true
        separateView.bottomAnchor.constraint(equalTo: buttonView.topAnchor).isActive = true
        
        buttonView.topAnchor.constraint(equalTo: profileView.bottomAnchor, constant: 8).isActive = true
        buttonView.leadingAnchor.constraint(equalTo: moreContentView.leadingAnchor).isActive = true
        buttonView.trailingAnchor.constraint(equalTo: moreContentView.trailingAnchor).isActive = true
        buttonView.heightAnchor.constraint(equalToConstant: 98).isActive = true

        couponButton.topAnchor.constraint(equalTo: buttonView.topAnchor).isActive = true
        couponButton.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor).isActive = true
        couponButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
        couponButton.widthAnchor.constraint(equalTo: cashButton.widthAnchor).isActive = true
        
        couponImageView.topAnchor.constraint(equalTo: couponButton.topAnchor, constant: 24).isActive = true
        couponImageView.centerXAnchor.constraint(equalTo: couponButton.centerXAnchor).isActive = true
        couponImageView.widthAnchor.constraint(equalTo: couponImageView.heightAnchor).isActive = true
        couponImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        couponTitleLabel.topAnchor.constraint(equalTo: couponImageView.bottomAnchor, constant: 6).isActive = true
        couponTitleLabel.centerXAnchor.constraint(equalTo: couponButton.centerXAnchor).isActive = true
        
        couponBadge.heightAnchor.constraint(equalToConstant: 16).isActive = true
        couponBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 16).isActive = true
        couponBadge.centerXAnchor.constraint(equalTo: couponButton.centerXAnchor, constant: 17).isActive = true
        couponBadge.bottomAnchor.constraint(equalTo: couponImageView.centerYAnchor).isActive = true
        
        separateView01.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 24).isActive = true
        separateView01.leadingAnchor.constraint(equalTo: couponButton.trailingAnchor).isActive = true
        separateView01.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        separateView01.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        cashButton.topAnchor.constraint(equalTo: buttonView.topAnchor).isActive = true
        cashButton.leadingAnchor.constraint(equalTo: separateView01.trailingAnchor).isActive = true
        cashButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
        cashButton.widthAnchor.constraint(equalTo: inviteFriendButton.widthAnchor).isActive = true
        
        cashImageView.topAnchor.constraint(equalTo: cashButton.topAnchor, constant: 24).isActive = true
        cashImageView.centerXAnchor.constraint(equalTo: cashButton.centerXAnchor).isActive = true
        cashImageView.widthAnchor.constraint(equalTo: cashImageView.heightAnchor).isActive = true
        cashImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        cashTitleLabel.topAnchor.constraint(equalTo: cashImageView.bottomAnchor, constant: 6).isActive = true
        cashTitleLabel.centerXAnchor.constraint(equalTo: cashButton.centerXAnchor).isActive = true
        
        separateView02.topAnchor.constraint(equalTo: buttonView.topAnchor, constant: 24).isActive = true
        separateView02.leadingAnchor.constraint(equalTo: cashButton.trailingAnchor).isActive = true
        separateView02.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        separateView02.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        inviteFriendButton.topAnchor.constraint(equalTo: buttonView.topAnchor).isActive = true
        inviteFriendButton.leadingAnchor.constraint(equalTo: separateView02.trailingAnchor).isActive = true
        inviteFriendButton.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor).isActive = true
        inviteFriendButton.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
        
        inviteFriendImageView.topAnchor.constraint(equalTo: inviteFriendButton.topAnchor, constant: 24).isActive = true
        inviteFriendImageView.centerXAnchor.constraint(equalTo: inviteFriendButton.centerXAnchor).isActive = true
        inviteFriendImageView.widthAnchor.constraint(equalTo: inviteFriendImageView.heightAnchor).isActive = true
        inviteFriendImageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        inviteFriendTitleLabel.topAnchor.constraint(equalTo: inviteFriendImageView.bottomAnchor, constant: 6).isActive = true
        inviteFriendTitleLabel.centerXAnchor.constraint(equalTo: inviteFriendButton.centerXAnchor).isActive = true
        
        moreTableView.topAnchor.constraint(equalTo: buttonView.bottomAnchor).isActive = true
        moreTableView.leadingAnchor.constraint(equalTo: moreContentView.leadingAnchor).isActive = true
        moreTableView.trailingAnchor.constraint(equalTo: moreContentView.trailingAnchor).isActive = true
        moreTableView.bottomAnchor.constraint(equalTo: moreContentView.bottomAnchor).isActive = true
        #if DEBUG || INHOUSE
//        moreTableView.heightAnchor.constraint(equalToConstant: 576).isActive = true
        moreTableView.heightAnchor.constraint(equalToConstant: 672).isActive = true
        #else
//        moreTableView.heightAnchor.constraint(equalToConstant: 480).isActive = true
        moreTableView.heightAnchor.constraint(equalToConstant: 512).isActive = true
        #endif
    }
    
}

// MARK: - UITableViewDataSource

extension MoreViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].numberOfItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: MoreMenuTableViewCell.self)
        cell.indexPath = indexPath
        cell.cellDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemIndexPath.accept((indexPath, items))
    }
     
}

extension MoreViewController: MoreMenuTableViewCellDelegate {
    func updateButtonAction() {
        Log.al("updateButtonAction")
        if let appStore = URL(string: API.APP_STORE_URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(appStore, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(appStore)
            }
        }
    }
    
}
// MARK: - UITableViewDelegate

extension MoreViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 32))
        headerView.backgroundColor = .grayTwoCw
        
        if section < items.count {
            let label = UILabel().then {
                $0.translatesAutoresizingMaskIntoConstraints = false
                $0.textColor = .brownishGrayCw
                $0.setFontToRegular(ofSize: 12)
            }
            label.text = items[section].rawValue
            
            headerView.addSubview(label)
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16).isActive = true
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        }
        return headerView
    }   
}
