//
//  CDCVActionSheet.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/14.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import RxDataSources
import SnapKit

class CDCVActionSheet: CashdocViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var getStackView: UIStackView!
    @IBOutlet weak var getScrollView: UIScrollView!
    
    private weak var collectionView: UICollectionView!
    
    var getTitleString = ""
    var didSelectCVData: ((String, String) -> Void)?
    var sectionList: [CDCVSectionModel] = [.init(image: "1", name: "a"),
                                           .init(image: "2", name: "b"),
                                           .init(image: "3", name: "c")
    ]
    var height: CGFloat = 392
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setProperty()
        self.bindView()
    }
    
    private func setProperty() {
        titleLabel.text = getTitleString
        
        let containerView: UIView = UIView().then {
            $0.backgroundColor = .white
            getStackView.addArrangedSubview($0)
        }
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
            let layout: UICollectionViewFlowLayout = .init()
            layout.scrollDirection = .vertical
            let itemSizeWidth: CGFloat = (ScreenSize.WIDTH / 3) - 16
            let itemSizeHeight: CGFloat = itemSizeWidth - 25
            layout.estimatedItemSize = CGSize(width: itemSizeWidth, height: itemSizeHeight)
            layout.minimumInteritemSpacing = 8
            layout.minimumLineSpacing = 8
            $0.backgroundColor = .white
            $0.collectionViewLayout = layout
            $0.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            $0.showsVerticalScrollIndicator = false
            $0.register(cellType: CDCollectionViewCell.self)
            containerView.addSubview($0)
            $0.snp.makeConstraints {(make) in
                make.height.equalTo(height)
                make.edges.equalToSuperview().inset(16)
            }
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
        
        var sectionItems: [CDCVSectionItem] = []
        for item: CDCVSectionModel in sectionList {
            sectionItems.append(.item(item: item))
        }
        let section: Observable<[CDCVSection]> = Observable.just([.section(items: sectionItems)])
        section
            .bind(to: collectionView.rx.items(dataSource: RxCollectionViewSectionedReloadDataSource<CDCVSection>(configureCell: { (_, cv, ip, item) -> UICollectionViewCell in
                switch item {
                case .item(let item):
                    let cell: CDCollectionViewCell = cv.dequeueReusableCell(for: ip, cellType: CDCollectionViewCell.self)
                    cell.configure(with: item)
                    return cell
                }
            })))
            .disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(CDCVSectionItem.self)
            .bind { [weak self] (item) in
                guard let self = self else { return }
                switch item {
                case .item(let item):
                    self.didSelectCVData?(item.image, item.name)
                    self.closeAct()
                }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func closeAct() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

// MARK: CDCollectionView Section 모델

struct CDCVSectionModel {
    let image: String
    let name: String
}

enum CDCVSection {
    case section(items: [CDCVSectionItem])
}

enum CDCVSectionItem {
    case item(item: CDCVSectionModel)
}

extension CDCVSection: SectionModelType {
    var items: [CDCVSectionItem] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: CDCVSection, items: [CDCVSectionItem]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}

// MARK: CDCollectionViewCell

final class CDCollectionViewCell: UICollectionViewCell {
    
    private weak var containerView: UIView!
    private weak var imageView: UIImageView!
    private weak var nameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: CDCVSectionModel) {
        imageView.image = UIImage(named: item.image)
        nameLabel.text = item.name
    }
    
    private func setProperties() {
        containerView = UIView().then {
            $0.clipsToBounds = true
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 0.5
            $0.layer.borderColor = UIColor.grayCw.cgColor
            contentView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        imageView = UIImageView().then {
            containerView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-8)
                make.size.equalTo(24)
            }
        }
        nameLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackCw
            $0.textAlignment = .center
            containerView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.centerX.equalTo(imageView)
                make.top.equalTo(imageView.snp.bottom).offset(4)
            }
            $0.snp.contentCompressionResistanceHorizontalPriority = UILayoutPriority.defaultHigh.rawValue
        }
    }
}
