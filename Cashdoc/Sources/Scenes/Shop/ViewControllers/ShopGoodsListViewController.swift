//
//  ShopGoodsListViewController.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import SafariServices

import Alamofire
import Then

final class ShopGoodsListViewController: CashdocViewController {
    
    // MARK: - Constants
    
    private enum Const {
        static let showShoppingDetailVC = "showShoppingDetailVC"
    }
    
    // MARK: - NSLayoutConstraints
    
    private var searchTableViewBottom: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var viewModel: ShopGoodsListViewModel!
    
    /// search list
    private var searchList = [ShopItemModel]()
    private var priceSort = 0
    private var searchText = ""
    
    /// shopping list
    private var goodsList = [ShopItemModel]()
    private var sectionRowCount = [Int]()
    private var headers = [String]()
    private var sectionGoodsList = [String: [ShopItemModel]]()
    var category: ShopCategoryModel?
    
    // MARK: - UI Components
    
    /// search list
    private lazy var rightBarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.tag = 0
        button.setTitleColor(.darkBrown, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textAlignment = .right
        button.setTitle("", for: .normal)
        button.setTitle("취소", for: .selected)
        button.setImage(UIImage(named: "icSearchBlack"), for: .normal)
        button.setImage(UIImage(), for: .selected)
        button.addTarget(self, action: #selector(rightBarButtonClicked), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        return button
    }()
    private let priceSortView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.isHidden = true
        $0.clipsToBounds = true
    }
    private let priceSortUnderscore = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white2
    }
    private let allPriceButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = .systemFont(ofSize: 14.0 * widthRatio, weight: .regular)
        $0.setTitle("모든 가격 대", for: .normal)
        $0.setTitleColor(.brownishGrayCw, for: .normal)
        $0.setTitleColor(.azureBlue, for: .selected)
        $0.setTitleColor(.azureBlue, for: .highlighted)
        $0.backgroundColor = .clear
        $0.tag = 0
        $0.isSelected = true
    }
    private let threeThousandButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = .systemFont(ofSize: 14.0 * widthRatio, weight: .regular)
        $0.setTitle("~3,000캐시", for: .normal)
        $0.setTitleColor(.brownishGrayCw, for: .normal)
        $0.setTitleColor(.azureBlue, for: .selected)
        $0.setTitleColor(.azureBlue, for: .highlighted)
        $0.backgroundColor = .clear
        $0.tag = 1
    }
    private let fiveThousandButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = .systemFont(ofSize: 14.0 * widthRatio, weight: .regular)
        $0.setTitle("~5,000캐시", for: .normal)
        $0.setTitleColor(.brownishGrayCw, for: .normal)
        $0.setTitleColor(.azureBlue, for: .selected)
        $0.setTitleColor(.azureBlue, for: .highlighted)
        $0.backgroundColor = .clear
        $0.tag = 2
    }
    private let fiveThousandOverButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = .systemFont(ofSize: 14.0 * widthRatio, weight: .regular)
        $0.setTitle("5,000캐시~", for: .normal)
        $0.setTitleColor(.brownishGrayCw, for: .normal)
        $0.setTitleColor(.azureBlue, for: .selected)
        $0.setTitleColor(.azureBlue, for: .highlighted)
        $0.backgroundColor = .clear
        $0.tag = 3
    }
    private lazy var searchView: ShopSearchView = {
        let view = ShopSearchView(frame: CGRect(x: 0, y: 0, width: ScreenSize.WIDTH, height: 36))
        view.delegate = self
        return view
    }()
    private let noSearchResultView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    private let noSearchResultImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgExclamationMark")
    }
    private let noSearchResultLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.text = "검색된 상품이 없습니다."
        $0.textColor = .brownishGray
        $0.textAlignment = .center
    }
    private var searchTableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
        $0.allowsSelection = true
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.keyboardDismissMode = .onDrag
        $0.register(cellType: ShoppingListCell.self)
    }
    
    /// shopping list
    private let profilePoint = ProfilePointView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    private let horizontalLine = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .lineGray
    }
    private let flowLayout = UICollectionViewFlowLayout().then {
        $0.scrollDirection = .horizontal
        $0.minimumLineSpacing = 0
        $0.minimumInteritemSpacing = 0
        $0.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    private lazy var shopCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.register(cellType: ShopAffiliateCell.self)
    }
    private let itemTableView = UITableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.keyboardDismissMode = .onDrag
        $0.register(cellType: ShoppingListCell.self)
    }
    
    // MARK: - Binding
    
    func bindViewModel() {
        itemTableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                Log.i(indexPath)
//                self.viewModel(category: self.goodsList[indexPath.row])
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Overridden: BaseViewController
    
//    override var backButtonTitleHidden: Bool {
//        return true
//    }
//
//    override func exceptionRetryButtonClicked() {
//        requestGetShopList()
//    }
//
//    override var networkExceptionShow: Bool {
//        return true
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        setProperties()
        setSelector()
        bindViewModel()
        
        /// shop
        view.addSubview(profilePoint)
        view.addSubview(horizontalLine)
        view.addSubview(shopCollectionView)
        view.addSubview(itemTableView)
        
        /// search
        view.addSubview(searchTableView)
        view.addSubview(noSearchResultView)
        view.addSubview(priceSortView)
        noSearchResultView.addSubview(noSearchResultImageView)
        noSearchResultView.addSubview(noSearchResultLabel)
        priceSortView.addSubview(allPriceButton)
        priceSortView.addSubview(threeThousandButton)
        priceSortView.addSubview(fiveThousandButton)
        priceSortView.addSubview(fiveThousandOverButton)
        priceSortView.addSubview(priceSortUnderscore)
        layout()
        
//        showLoading()
        requestGetShopList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        profilePoint.refreshView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard segue.identifier == Const.showShoppingDetailVC, let controller = segue.destination as? ShoppingDetailVC else {return}
//        guard let item = sender as? ShopItemModel, let goodsId = item.goodsId else {return}
//        controller.goodsId = goodsId
    }
    
    // MARK: - Private methods
    
    private func requestGetShopList() {
        let shopUseCase = ShopUseCase()
        let categoryString = String(category?.id ?? 1)
        shopUseCase.getItemList(listId: categoryString).drive(onNext: { [weak self] (result) in
            guard let self = self else {return}
            defer {
                DispatchQueue.main.async {
                    self.shopCollectionView.reloadData()
                    self.itemTableView.reloadData()
                }
            }
            
            guard let resultArray = result.result else {return}
            
            for goods in resultArray {
                guard let affiliate = goods.affiliate else {return}
                if self.sectionGoodsList[affiliate] == nil {
                    self.sectionGoodsList[affiliate] = [ShopItemModel]()
                }

                self.sectionGoodsList[affiliate]?.append(goods)
                for i in 0 ..< self.headers.count where self.headers[i] == affiliate {
                    self.sectionRowCount[i] += 1
                    break
                }
            }

            for (i, h) in self.headers.enumerated() {
                if self.sectionGoodsList[h] == nil {
                    self.headers.remove(at: i)
                    self.sectionRowCount.remove(at: i)
                    self.category?.affiliates?.remove(at: i)
                    continue
                }
                for g in self.sectionGoodsList[h]! {
                    self.goodsList.append(g)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func setDelegate() {
        shopCollectionView.delegate = self
        shopCollectionView.dataSource = self
        itemTableView.delegate = self
        itemTableView.dataSource = self
        searchTableView.delegate = self
        searchTableView.dataSource = self
    }
    
    private func setProperties() {
        view.backgroundColor = .white
        itemTableView.contentInsetAdjustmentBehavior = .never
        searchTableView.contentInsetAdjustmentBehavior = .never
        category?.affiliates?.forEach({ (cate) in
            guard let title = cate.title else {return}
            headers.append(title)
        })
        sectionRowCount = Array(repeating: 0, count: headers.count)
        title = category?.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)
    }
    
    private func setSelector() {
        allPriceButton.addTarget(self, action: #selector(priceSortButtonClicked), for: .touchUpInside)
        threeThousandButton.addTarget(self, action: #selector(priceSortButtonClicked), for: .touchUpInside)
        fiveThousandButton.addTarget(self, action: #selector(priceSortButtonClicked), for: .touchUpInside)
        fiveThousandOverButton.addTarget(self, action: #selector(priceSortButtonClicked), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(noti:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func showSearchBar() {
        navigationItem.hidesBackButton = true
        navigationItem.titleView = searchView
        rightBarButton.isSelected = true
        priceSortView.isHidden = false
        searchView.textField.becomeFirstResponder()
    }
    
    private func hideSearchBar() {
        searchView.textField.resignFirstResponder()
        rightBarButton.isSelected = false
        navigationItem.titleView?.removeFromSuperview()
        navigationItem.titleView = nil
        navigationItem.hidesBackButton = false
        
        allPriceButton.isSelected = true
        threeThousandButton.isSelected = false
        fiveThousandButton.isSelected = false
        fiveThousandOverButton.isSelected = false
        priceSort = 0
        searchText = ""
        searchView.textField.text = ""
        searchList.removeAll()
        priceSortView.isHidden = true
        searchTableView.isHidden = true
        noSearchResultView.isHidden = true
        searchTableView.reloadData()
    }
    
    private func startSearch(completion: (Bool, Int) -> Void) {
        if searchView.textField.text == "" {
            noSearchResultView.isHidden = true
            searchTableView.isHidden = true
            completion(true, 0)
        } else {
            let arrSearchList = goodsList.filter {
                let title = $0.title == nil ? "":$0.title!
                let price = $0.price == nil ? 0:$0.price!
                if priceSort == 0 {
                    return title.lowercased().contains(searchView.textField.text!.lowercased())
                    } else if priceSort == 5001 {
                    return title.lowercased().contains(searchView.textField.text!.lowercased()) && price >= (priceSort-1)
                } else {
                    return title.lowercased().contains(searchView.textField.text!.lowercased()) && price <= priceSort
                }
            }
            
            if arrSearchList.count > 0 {
                searchText = searchView.textField.text!
                searchList.removeAll()
                searchList = arrSearchList
            }
            completion(false, arrSearchList.count)
        }
    }
    
    // MARK: - Private selector
    
    @objc private func rightBarButtonClicked() {
        if rightBarButton.isSelected == false {
            showSearchBar()
        } else {
            hideSearchBar()
        }
    }
    
    @objc private func priceSortButtonClicked(button: UIButton) {
        button.isSelected = true
        switch button.tag {
        case 0:
            priceSort = 0
            threeThousandButton.isSelected = false
            fiveThousandButton.isSelected = false
            fiveThousandOverButton.isSelected = false
        case 1:
            priceSort = 3000
            allPriceButton.isSelected = false
            fiveThousandButton.isSelected = false
            fiveThousandOverButton.isSelected = false
        case 2:
            priceSort = 5000
            allPriceButton.isSelected = false
            threeThousandButton.isSelected = false
            fiveThousandOverButton.isSelected = false
        case 3:
            priceSort = 5001
            allPriceButton.isSelected = false
            threeThousandButton.isSelected = false
            fiveThousandButton.isSelected = false
        default:
            break
        }
        
        startSearch { (isSearchTextNil, arrSearchListCount) in
            if isSearchTextNil == false {
                if arrSearchListCount > 0 {
                    noSearchResultView.isHidden = true
                    searchTableView.isHidden = false
                } else {
                    noSearchResultView.isHidden = false
                }
                searchTableView.reloadData()
            }
        }
    }
    
    @objc private func showKeyboard(noti: NSNotification) {
        guard let keyboardFrame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, let duration = noti.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        
        var keyboardHeight = keyboardFrame.cgRectValue.height
        guard let window = UIApplication.shared.keyWindow else {return}
        keyboardHeight -= (window.safeAreaInsets.bottom)
        UIView.animate(withDuration: TimeInterval(truncating: duration), animations: {
            self.searchTableViewBottom.constant = -keyboardHeight
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func hideKeyboard(noti: NSNotification) {
        guard let duration = noti.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        
        UIView.animate(withDuration: TimeInterval(truncating: duration), animations: {
            self.searchTableViewBottom.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
}

// MARK: - Layout

extension ShopGoodsListViewController {
    
    private func layout() {
        profilePoint.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        profilePoint.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        profilePoint.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        profilePoint.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        horizontalLine.topAnchor.constraint(equalTo: profilePoint.bottomAnchor).isActive = true
        horizontalLine.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        horizontalLine.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        horizontalLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        shopCollectionView.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        shopCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        shopCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        shopCollectionView.heightAnchor.constraint(equalToConstant: 106).isActive = true
        
        itemTableView.topAnchor.constraint(equalTo: shopCollectionView.bottomAnchor).isActive = true
        itemTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        itemTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        itemTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        searchLayout()
    }
    private func searchLayout() {
        priceSortView.topAnchor.constraint(equalTo: profilePoint.topAnchor).isActive = true
        priceSortView.leadingAnchor.constraint(equalTo: profilePoint.leadingAnchor).isActive = true
        priceSortView.trailingAnchor.constraint(equalTo: profilePoint.trailingAnchor).isActive = true
        priceSortView.heightAnchor.constraint(equalTo: profilePoint.heightAnchor).isActive = true
        
        priceSortUnderscore.leadingAnchor.constraint(equalTo: priceSortView.leadingAnchor).isActive = true
        priceSortUnderscore.trailingAnchor.constraint(equalTo: priceSortView.trailingAnchor).isActive = true
        priceSortUnderscore.bottomAnchor.constraint(equalTo: priceSortView.bottomAnchor).isActive = true
        priceSortUnderscore.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        searchTableView.topAnchor.constraint(equalTo: horizontalLine.bottomAnchor).isActive = true
        searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchTableViewBottom = searchTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        searchTableViewBottom.isActive = true
        
        allPriceButton.topAnchor.constraint(equalTo: priceSortView.topAnchor).isActive = true
        allPriceButton.leadingAnchor.constraint(equalTo: priceSortView.leadingAnchor, constant: 16).isActive = true
        allPriceButton.bottomAnchor.constraint(equalTo: priceSortUnderscore.topAnchor).isActive = true
        allPriceButton.widthAnchor.constraint(equalTo: fiveThousandOverButton.widthAnchor).isActive = true
        
        threeThousandButton.leadingAnchor.constraint(equalTo: allPriceButton.trailingAnchor, constant: 13).isActive = true
        threeThousandButton.centerYAnchor.constraint(equalTo: allPriceButton.centerYAnchor).isActive = true
        threeThousandButton.widthAnchor.constraint(equalTo: allPriceButton.widthAnchor).isActive = true
        threeThousandButton.heightAnchor.constraint(equalTo: allPriceButton.heightAnchor).isActive = true
        
        fiveThousandButton.leadingAnchor.constraint(equalTo: threeThousandButton.trailingAnchor, constant: 13).isActive = true
        fiveThousandButton.centerYAnchor.constraint(equalTo: allPriceButton.centerYAnchor).isActive = true
        fiveThousandButton.widthAnchor.constraint(equalTo: threeThousandButton.widthAnchor).isActive = true
        fiveThousandButton.heightAnchor.constraint(equalTo: allPriceButton.heightAnchor).isActive = true
        
        fiveThousandOverButton.leadingAnchor.constraint(equalTo: fiveThousandButton.trailingAnchor, constant: 13).isActive = true
        fiveThousandOverButton.trailingAnchor.constraint(equalTo: priceSortView.trailingAnchor, constant: -16).isActive = true
        fiveThousandOverButton.centerYAnchor.constraint(equalTo: allPriceButton.centerYAnchor).isActive = true
        fiveThousandOverButton.heightAnchor.constraint(equalTo: allPriceButton.heightAnchor).isActive = true
        
        noSearchResultViewLayout()
    }
    
    private func noSearchResultViewLayout() {
        noSearchResultView.topAnchor.constraint(equalTo: searchTableView.topAnchor).isActive = true
        noSearchResultView.leadingAnchor.constraint(equalTo: searchTableView.leadingAnchor).isActive = true
        noSearchResultView.trailingAnchor.constraint(equalTo: searchTableView.trailingAnchor).isActive = true
        noSearchResultView.bottomAnchor.constraint(equalTo: searchTableView.bottomAnchor).isActive = true
        
        noSearchResultImageView.centerXAnchor.constraint(equalTo: noSearchResultView.centerXAnchor).isActive = true
        noSearchResultImageView.centerYAnchor.constraint(equalTo: noSearchResultView.centerYAnchor, constant: -20).isActive = true
        noSearchResultImageView.widthAnchor.constraint(equalToConstant: 56).isActive = true
        noSearchResultImageView.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        noSearchResultLabel.topAnchor.constraint(equalTo: noSearchResultImageView.bottomAnchor, constant: 10).isActive = true
        noSearchResultLabel.centerXAnchor.constraint(equalTo: noSearchResultView.centerXAnchor).isActive = true
    }
    
}

// MARK: - ShoppingSearchViewDelegate

extension ShopGoodsListViewController: ShopSearchViewDelegate {
    
    func shoppingSearchViewDidClickedSearchButton(_ view: ShopSearchView) {
        startSearch { (isSearchTextNil, arrSearchListCount) in
            if isSearchTextNil == false, arrSearchListCount <= 0 {
                noSearchResultView.isHidden = false
                searchTableView.isHidden = false
                searchTableView.reloadData()
            }
        }
        
//        if let tracker = GAI.sharedInstance().defaultTracker {
//            tracker.send(GAIDictionaryBuilder.createEvent(withCategory: "SHOPPING",
//                                                          action: category?.title,
//                                                          label: searchText,
//                                                          value: nil).build() as! [AnyHashable: Any])
//        }
    }
    
    func shoppingSearchViewDidChangeText(_ view: ShopSearchView) {
        startSearch { (isSearchTextNil, arrSearchListCount) in
            if isSearchTextNil == false, arrSearchListCount > 0 {
                noSearchResultView.isHidden = true
                searchTableView.isHidden = false
                searchTableView.reloadData()
            }
        }
    }
    
}

// MARK: - UITableViewDataSource

extension ShopGoodsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == searchTableView {
            return 1
        } else {
            return headers.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchTableView {
            return searchList.count
        } else {
            return sectionRowCount[section]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ShoppingListCell.self)
        
        if tableView == searchTableView {
            if searchList.count > 0 {
                cell.configuration(item: searchList[indexPath.row], searchString: searchText)
            }
        } else {
            if goodsList.count <= 0 {
                return cell
            }
            var index = 0
            for i in 0 ..< indexPath.section {
                index += sectionRowCount[i]
            }
            
            index += indexPath.row
            cell.configuration(item: goodsList[index], searchString: "")
        }
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ShopGoodsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 113
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchView.textField.resignFirstResponder()
        if tableView == searchTableView {
//            performSegue(withIdentifier: Const.showShoppingDetailVC, sender: searchList[indexPath.row])
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            var index = 0
            for i in 0 ..< indexPath.section {
                index += sectionRowCount[safe: i] ?? 0
            }
            index += indexPath.row

            Log.i(goodsList[index])
            viewModel.pushShopDetailVC(item: goodsList[index])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView != searchTableView {
            let titleView = UIView().then {
                $0.backgroundColor = .white3
            }
            let titleLabel = UILabel(frame: CGRect(x: 16, y: 0, width: 200, height: 24)).then {
                $0.setFontToRegular(ofSize: 12)
                $0.textColor = .blackTwoCw
                $0.text = headers[section]
            }
            
            titleView.addSubview(titleLabel)
            
            return titleView
        }
        
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView != searchTableView {
            return 24
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension ShopGoodsListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let affiliates = category?.affiliates else {return 0}
        return affiliates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ShopAffiliateCell.self)
        guard let affiliates = category?.affiliates else {return cell}
        cell.affiliate = affiliates[indexPath.section]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ip = IndexPath(row: 0, section: indexPath.section)
        guard indexPath.section <= itemTableView.numberOfSections else {return}
        itemTableView.CDScrollToRow(at: ip, at: .top, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 82, height: collectionView.bounds.height)
    }
    
    private func indexPathIsValid(with indexPath: IndexPath) -> Bool {
        return indexPath.section < numberOfSections(in: shopCollectionView) &&
            indexPath.row < shopCollectionView.numberOfItems(inSection: indexPath.section)
    }
}
