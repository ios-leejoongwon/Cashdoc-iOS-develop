//
//  CpqListViewController.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

final class CpqListViewController: CashdocViewController {
    
    // MARK: - NSLayoutConstraints
    
    private var bannerVCHeight: NSLayoutConstraint!
    private var tableViewHeight: NSLayoutConstraint!
    private var comingViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    
    private var comingTimer: Timer?
    
    private var quizComing = String() {
        didSet {
            self.removeComingTimer()
            self.startComingTimer()
        }
    }
    private var arrCpqList = [CpqListModel]() {
        didSet {
            if let beginDate = self.arrCpqList.last?.beginDate {
                self.beginDate = beginDate
            }
            self.isArrCpqListEmpty = false
            self.reloadTableView()
        }
    }
    
    private var beginDate: String?
    private var isArrCpqListEmpty: Bool = false
    private var categorys = [ShopCategoryModel]()
    
    // MARK: - UI Components
    
    private var navigationBarView: UIView!
    private var bannerVC: CashdocBannerViewController!
    private var containerView: UIView!
    private var scrollView: UIScrollView!
    private var quizComingBgView: UIView!
    private var quizComingView: UIView!
    private var quizComingLabel: UILabel!
    private var quizTimeBoxImageView: UIImageView!
    private var quizComingTimeLabel: UILabel!
    private var quizComingHorizontalLine: UILabel!
    private var whiteBgView: UIView!
    private var tableView: UITableView!
    private var networkErrorView: UIView!
    private var errorBackgroundView: UIView!
    private var errorImageView: UIImageView!
    private var errorLabel: UILabel!
    private var rightBarButtonItem: UIBarButtonItem!
    private var isEnabledRelodeData: Bool = false
      
    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: BaseViewController
    
    //    override var backButtonTitleHidden: Bool {
    //        return true
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setUI()
        setDelegate()
        bindView()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        rightBarButtonItem.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                let controller = CpqGuideViewController()
                self.navigationController?.pushViewController(controller, animated: true)
                
        }
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setUI() {
        rightBarButtonItem = UIBarButtonItem().then {
            $0.image = UIImage(named: "icQuestionBlack")
            $0.style = .plain
            navigationItem.rightBarButtonItem = $0
        }
        containerView = UIView().then {
            $0.backgroundColor = .white
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.leading.trailing.bottom.equalTo(view)
            }
        }
        scrollView = UIScrollView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.alwaysBounceVertical = true
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = .white
            containerView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.leading.trailing.height.equalTo(containerView)
            }
        }
        
        bannerVC = CashdocBannerViewController(position: .quiz).then {
            addChild($0)
            scrollView.addSubview($0.view)
            $0.view.snp.makeConstraints {
                $0.top.equalTo(scrollView)
                $0.leading.trailing.equalTo(containerView)
            }
            bannerVCHeight = $0.view.heightAnchor.constraint(equalTo: $0.view.widthAnchor, multiplier: 3.7/10)
            bannerVCHeight.isActive = true
        }
        
        quizComingBgView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.isHidden = true
            scrollView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(bannerVC.view.snp.bottom)
                $0.leading.trailing.equalTo(containerView)
            }
            comingViewHeight = $0.heightAnchor.constraint(equalToConstant: 0)
            comingViewHeight.isActive = true
        }
        quizComingView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.fromRGB(72, 65, 65)
            $0.layer.cornerRadius = 6
            $0.clipsToBounds = true
            quizComingBgView.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerX.centerY.equalTo(quizComingBgView)
                $0.leading.equalTo(quizComingBgView).offset(16)
                $0.trailing.equalTo(quizComingBgView).offset(-16)
                $0.height.equalTo(48)
            }
        }
        quizComingLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "다음 퀴즈까지 남은 시간 ⏰"
            $0.textColor = .white
            $0.textAlignment = .left
            $0.numberOfLines = 1
            $0.minimumScaleFactor = 0.5
            $0.adjustsFontSizeToFitWidth = true
            $0.font = .systemFont(ofSize: 16, weight: .light)
            let font = UIFont.systemFont(ofSize: 16, weight: .medium)
            let attributedStr = NSMutableAttributedString(string: $0.text!)
            attributedStr.addAttribute(NSAttributedString.Key.font, value: font, range: ($0.text! as NSString).range(of: "다음 퀴즈"))
            $0.attributedText = attributedStr
            quizComingView.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalTo(quizComingView)
                $0.leading.equalTo(quizComingView).offset(14)
            }
        }
        quizTimeBoxImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = UIImage(named: "imgQuizTimebox")
            quizComingView.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.equalTo(quizComingView)
                $0.top.equalTo(quizComingView).offset(6)
                $0.bottom.equalTo(quizComingView).offset(-6)
                $0.leading.greaterThanOrEqualTo(quizComingLabel.snp.trailing).offset(10)
                $0.trailing.equalTo(quizComingView).offset(-8)
            }
        }
        quizComingTimeLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "23 : 59 : 59"
            $0.textColor = UIColor.fromRGB(255, 210, 0)
            $0.textAlignment = .center
            $0.numberOfLines = 1
            $0.minimumScaleFactor = 0.5
            $0.adjustsFontSizeToFitWidth = true
            $0.font = .systemFont(ofSize: 20, weight: .medium)
            quizComingView.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerY.centerX.equalTo(quizTimeBoxImageView)
            }
        }
        quizComingHorizontalLine = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.fromRGB(229, 229, 229)
            quizComingBgView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(quizComingBgView.snp.bottom).offset(-1)
                $0.leading.trailing.equalTo(containerView)
                $0.bottom.equalTo(containerView)
                $0.height.equalTo(1)
            }
        }
        whiteBgView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            scrollView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(quizComingBgView.snp.bottom)
                $0.leading.trailing.bottom.equalTo(containerView)
            }
        }
        tableView = UITableView(frame: .zero, style: .plain).then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isScrollEnabled = false
            $0.backgroundColor = .white
            $0.estimatedRowHeight = 118.5
            $0.rowHeight = UITableView.automaticDimension
            $0.separatorColor = .clear
            $0.register(cellType: CpqListCell.self)
            scrollView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(quizComingBgView.snp.bottom)
                $0.leading.trailing.equalTo(containerView)
                $0.bottom.equalTo(scrollView.snp.bottom)
            }
            tableViewHeight = $0.heightAnchor.constraint(equalToConstant: 0)
            tableViewHeight.isActive = true
        }
        networkErrorView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.isHidden = true
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.leading.trailing.bottom.equalTo(view)
            }
        }
        errorBackgroundView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            networkErrorView.addSubview($0)
            $0.snp.makeConstraints {
                $0.centerX.centerY.equalTo(networkErrorView)
                $0.width.equalTo(194)
                $0.height.equalTo(135)
            }
        }
        errorImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = UIImage(named: "imgPresentError")
            errorBackgroundView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(errorBackgroundView)
                $0.centerX.equalTo(networkErrorView)
                $0.width.height.equalTo(67)
            }
        }
        errorLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "현재 네트워크 상태가 원활하지 않으니 잠시 후 다시 시도해주세요."
            $0.textColor = .brownishGrayCw
            $0.textAlignment = .center
            $0.numberOfLines = 3
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            errorBackgroundView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(errorImageView.snp.bottom)
                $0.centerX.equalTo(networkErrorView)
                $0.width.equalTo(194)
                $0.height.equalTo(60)
            }
        }
        navigationBarView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.fromRGB(255, 210, 0)
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.leading.trailing.equalTo(view)
                if #available(iOS 11.0, *) {
                    $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
                } else {
                    $0.bottom.equalTo(view.snp.top)
                }
            }
        }
    }
    
    private func setDelegate() {
        bannerVC.delegate = self
        scrollView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func reloadTableView() {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.tableViewHeight.constant = self.tableView.contentSize.height
            self.view.layoutIfNeeded()
        }
        tableView.reloadData()
        CATransaction.commit()
    }
    
    private func requestData(lastDate: String? = nil) {
        CpqManager.shared.getCpqList(live: 0, lastDate: lastDate) { (error, result) in
            #if CASHDOC
            GlobalFunction.CDHideLogoLoadingView()
            #endif
            guard error == nil, let result = result else {return}
            if let arrCpqList = result.list {
                let sortedArrCpqList = arrCpqList.sorted(by: {
                    return ($0.lock ?? 0 < $1.lock ?? 0)
                })
                
                if lastDate != nil {
                    // 페이지네이션 요청 시, 빈 배열이 오면(끝나면) isArrCpqListEmpty true로 변경하여 다음 willDisplay에서부터 request 실행 안되도록 함.
                    if arrCpqList.isEmpty {
                        self.isArrCpqListEmpty = true
                        self.isEnabledRelodeData = false
                        return
                    }
                    // 퀴즈 진행 예정 시간이 0 이하가 되서, 다음 퀴즈가 진행되는 경우 새로운 리스트로 교체함.
                    if let quizComing = result.coming,
                        let interval = self.makeIntervalWithQuizComing(quizComing),
                        interval <= 0 {
                        self.arrCpqList = sortedArrCpqList
                    } else {
                        self.arrCpqList.append(contentsOf: sortedArrCpqList)
                    }
                } else {
                    if let quizComing = result.coming {
                        self.quizComing = quizComing
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                        dateFormatter.dateFormat = SERVER_DATE_FORMAT
                        
                        if let endDate = dateFormatter.date(from: quizComing) {
                            let makeSecond = Date().seconds(from: endDate)
                            if makeSecond < 0 {
                                self.comingViewHeight.constant = 88
                                self.quizComingBgView.isHidden = false
                                self.setQuizComingTime()
                                self.removeComingTimer()
                                self.startComingTimer()
                            } else {
                                self.removeComingTimer()
                                self.comingViewHeight.constant = 0
                                self.quizComingBgView.isHidden = true
                            }
                        } else {
                            self.removeComingTimer()
                            self.comingViewHeight.constant = 0
                            self.quizComingBgView.isHidden = true
                        }
                    } else {
                        self.removeComingTimer()
                        self.comingViewHeight.constant = 0
                        self.quizComingBgView.isHidden = true
                    }
                    self.arrCpqList = sortedArrCpqList
                    self.isEnabledRelodeData = false
                }
            }
        }
    }
    
    @objc private func setQuizComingTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.dateFormat = SERVER_DATE_FORMAT
        
        let startDate = Date()
        if let endDate = dateFormatter.date(from: quizComing) {
            let interval = endDate.timeIntervalSince(startDate) + 1.0
            dateFormatter.dateFormat = "HH : mm : ss"
            let quizComingDate = Date(timeIntervalSince1970: interval)
            let dateString = dateFormatter.string(from: quizComingDate)
            quizComingTimeLabel.text = dateString
            
            if interval <= 0 {
                removeComingTimer()
                #if CASHDOC
                GlobalFunction.CDShowLogoLoadingView()
                #endif
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: {
                    self.requestData()
                })
            }
        }
    }
    
    private func setProperties() {
        title = "용돈퀴즈"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        self.navigationController?.navigationBar.backgroundColor = UIColor.fromRGB(255, 210, 0)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard ReachabilityManager.reachability.connection != .unavailable else {
            networkErrorView.isHidden = false
            return self.view.makeToastWithCenter("네트워크 연결 상태를 확인해주세요.")
        }
        bannerVC.requestGetBanner(position: .quiz)
        GlobalFunction.CDShowLogoLoadingView()
        requestData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeComingTimer()
        GlobalDefine.shared.isPossibleShowPopup = true
        
    }
    
    private func makeIntervalWithQuizComing(_ quizComing: String) -> Double? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.dateFormat = SERVER_DATE_FORMAT
        guard let endDate = dateFormatter.date(from: quizComing) else { return nil }
        let interval = endDate.timeIntervalSince(Date()) + 1.0
        return interval
    }
    
}

// MARK: - CashwalkBannerVCDelegate
 
extension CpqListViewController: CashdocBannerViewControllerDelegate {
    func cashdocBannerVCDidClicked(_ viewController: CashdocBannerViewController, banner: AdBannerModel) {
        guard let url = banner.url else {return}
        
        guard !url.contains("http") else {
            let linkType = banner.linkType ?? 0
            let order = banner.order ?? 0
            if linkType == 1 {
                LinkManager.open(type: .inLink(rootViewController: self), url: url)
            } else if linkType == 2 {
                LinkManager.open(type: .outLink, url: url)
            } else {
                guard order == 0 else {
                    LinkManager.open(type: .inLink(rootViewController: self), url: url)
                    return
                }
                LinkManager.open(type: .outLink, url: url)
            }
            return
        }
        
        guard !url.contains("id") else {
            guard let quizId = url.split(separator: "=").last else { return }
            let controller = CpqDetailViewController()
            controller.quizID = String(quizId)
            navigationController?.pushViewController(controller, animated: true)
            return
        }
    }
    
    func cashdocBannerVCRequestGetBannerEmptyOrError(_ viewController: CashdocBannerViewController) {
        bannerVCHeight.constant -= viewController.view.frame.height
        view.layoutIfNeeded()
    }
}

// MARK: - UITableViewDataSource

extension CpqListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCpqList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CpqListCell.self)
        cell.cpqListtModel = arrCpqList[safe: indexPath.row]
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CpqListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CpqListCell else {return}
        let controller = CpqDetailViewController()
        if let cpqModel = cell.cpqListtModel, let id = cpqModel.id {
            controller.quizID = id
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        Log.al("willDisplay isEnabledRelodeData = \(isEnabledRelodeData)")
//        let lastCount: Int = self.arrCpqList.count - 1
//        if indexPath.row == lastCount, self.isEnabledRelodeData, !self.isArrCpqListEmpty {
//          self.requestData(lastDate: self.beginDate)
//            
//        }
    }
}

// MARK: - Timer

extension CpqListViewController {
    private func startComingTimer() {
        comingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setQuizComingTime), userInfo: nil, repeats: true)
    }
    
    private func removeComingTimer() {
        comingTimer?.invalidate()
        comingTimer = nil
    }
}

extension CpqListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height - scrollView.frame.size.height
        Log.al("offsetY = \(offsetY), contentHeight = \(contentHeight)")
        if offsetY > contentHeight {
            //            isEnabledRelodeData = true
            if !self.isArrCpqListEmpty {
                self.requestData(lastDate: self.beginDate)
            }
        }
    }
}
