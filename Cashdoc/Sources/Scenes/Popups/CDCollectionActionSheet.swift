//
//  CDCollectionActionSheet.swift
//  Cashdoc
//
//  Created by Taejune Jung on 08/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum CollectionActionSheetType: String {
    case 지출
    case 수입
    case 기타
}

class CDCollectionActionSheet: CashdocViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var getStackView: UIStackView!
    @IBOutlet weak var getScrollView: UIScrollView!
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        $0.collectionViewLayout = layout
        $0.contentInset = UIEdgeInsets(top: 8, left: 16, bottom: 16, right: 16)
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        $0.showsVerticalScrollIndicator = false
        $0.register(cellType: ConsumeCategoryCollectionViewCell.self)
    }
    var emptyView: UIView?
    var getTitleString = "카테고리 선택"
    var type: CollectionActionSheetType = .지출
    var didSelectIndex: ((ConsumeCategorySectionItem) -> Void)?
    var sections = [ConsumeCategorySection]() {
        didSet {
            self.itemCount = sections.first?.items.count ?? 0
        }
    }
    var itemCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setProperty()
        self.layout()
        self.bindView()
    }
    
    private func setProperty() {
        titleLabel.text = getTitleString
        if DeviceType.IS_IPHONE_X_MORE {
            emptyView = UIView().then {
                $0.backgroundColor = UIColor.white
                self.view.addSubview($0)
                $0.snp.makeConstraints({
                    $0.height.equalTo(53)
                })
            }
        }
    }
    
    private func layout() {
        getStackView.addArrangedSubview(collectionView)
        if let emptyView = self.emptyView {
            getStackView.addArrangedSubview(emptyView)
        }
        collectionView.snp.makeConstraints {
            var lineCnt = ceil(Double(Double(itemCount) / 3))
            if lineCnt == 0 {
                lineCnt = 1
            }
            $0.height.equalTo(CGFloat(85 * lineCnt) + collectionView.contentInset.top + collectionView.contentInset.bottom + CGFloat((lineCnt - 1) * 8))
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
        
        Observable.just(sections)
            .bind(to: collectionView.rx.items(dataSource: self.dataSource()))
        .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                let item = self.sections[index.section].items[index.row]
                self.didSelectIndex?(item)
                self.closeAct()
            })
        .disposed(by: disposeBag)
        
    }
    
    @IBAction func closeAct() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

}
extension CDCollectionActionSheet {
    private func dataSource() -> RxCollectionViewSectionedReloadDataSource<ConsumeCategorySection> {
        return RxCollectionViewSectionedReloadDataSource<ConsumeCategorySection>(configureCell: { (_, cv, ip, item) in
            switch item {
            case .category(category: let category):
                let cell = cv.dequeueReusableCell(for: ip, cellType: ConsumeCategoryCollectionViewCell.self)
                cell.configure(with: category)
                return cell
            case .test(item: _):
                print("임시입니다.")
                return UICollectionViewCell()
            }
        })
    }
}
