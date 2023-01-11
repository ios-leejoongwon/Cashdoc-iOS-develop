//
//  SelectCertificateViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 08/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

struct SelectCertificateResult {
    let item: CertificateSectionItem
    let bankName: String
    let type: LinkPropertyChildType
}

final class SelectCertificateViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var viewModel: SelectCertificateViewModel!
    private var propertyType: LinkPropertyChildType!
    private var bankName: String!
    private var tableViewHeight: NSLayoutConstraint!
    private let reloadTrigger = PublishRelay<Void>()
    
    // MARK: - UI Components
    
    private let certContentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        $0.isHidden = true
    }
    private let emptyContentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
    }
    private let centerImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgCertificationNoneBig")
    }
    private let descLabel1 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "저장된 공동인증서(구 공인인증서)가 없어요."
    }
    private let descLabel2 = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "등록된 공동인증서는 안전하게 보호되며\n캐시닥 서비스 연동에 사용됩니다."
    }
    private let importCertButtonWhenNotHave = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .yellowCw
        $0.layer.cornerRadius = 4
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.setTitle("공동인증서 가져오기", for: .normal)
    }
    private let certTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.text = "공동인증서를 선택해 주세요."
    }
    private let tableView = SelfSizedTableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.estimatedRowHeight = 65
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        $0.clipsToBounds = true
        $0.register(cellType: CertificateTableViewCell.self)
    }
    private let importCertButtonWhenHave = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .clear
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.setTitleColor(.blackCw, for: .normal)
        $0.titleLabel?.textAlignment = .center
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let buttonString = NSAttributedString(string: "PC에서 공동인증서 가져오기", attributes: underlineAttribute)
        $0.setAttributedTitle(buttonString, for: .normal)
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: SelectCertificateViewModel,
         propertyType: LinkPropertyChildType,
         bankName: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
        self.propertyType = propertyType
        self.bankName = bankName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindViewModel()
        view.addSubview(emptyContentView)
        view.addSubview(certContentView)
        emptyContentView.addSubview(centerImage)
        emptyContentView.addSubview(descLabel1)
        emptyContentView.addSubview(descLabel2)
        emptyContentView.addSubview(importCertButtonWhenNotHave)
        certContentView.addSubview(certTitleLabel)
        certContentView.addSubview(tableView)
        certContentView.addSubview(importCertButtonWhenHave)
        layout()
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).mapToVoid()
        let selection = tableView.rx.modelSelected(CertificateSectionItem.self).asObservable().map { (item) in
            (SelectCertificateResult(item: item, bankName: self.bankName, type: self.propertyType))
        }
        let clickedImportButton = Driver.merge(importCertButtonWhenNotHave.rx.tap.asDriverOnErrorJustNever(),
                                               importCertButtonWhenHave.rx.tap.asDriverOnErrorJustNever())
            .map {self.bankName}
            .filterNil()
        let input = type(of: self.viewModel).Input(trigger: viewWillAppear.asDriverOnErrorJustNever(),
                                              selection: selection.asDriverOnErrorJustNever(),
                                              clickedImportButton: clickedImportButton)
        
        let output = viewModel.transform(input: input)
        
        tableView.rx.observe(CGSize.self, "contentSize")
            .subscribe(onNext: { [weak self] (size) in
                guard let self = self else { return }
                guard let size = size, self.tableViewHeight != nil else { return }
                self.tableViewHeight.constant = size.height + 110
            })
            .disposed(by: disposeBag)
        
        output.checkHaveCertificateFetching
            .drive(onNext: { [weak self] (isHaveCertificate) in
                guard let self = self else { return }
                self.didChangeContentView(isHaveCertificate)
            })
            .disposed(by: disposeBag)
        
        output.sections
            .drive(tableView.rx.items(dataSource: self.dataSource()))
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.navigationItem.title = "공동인증서 로그인"
        
        // 하단에 ISMS용 문구추가
        let makeTableFooter = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 110)
        }
                
        let infoLabel = UILabel().then {
            $0.text = "- 공동인증서 비밀번호는 고객님 핸드폰에만 저장되며,\n 서비스 조회 목적 외에 다른 용도로 사용되지 않습니다."
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .brownishGray
            $0.setLineHeight(lineHeight: 20)
            makeTableFooter.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview().offset(15)
                m.left.equalToSuperview().offset(16)
                m.right.equalToSuperview().inset(16)
            }
        }
        
        _ = UILabel().then {
            $0.text = "- 미국 NASA에서 사용하는 SSL/TLS 및 AES-256 암호화\n 알고리즘을 적용해 고객님의 개인정보는 안전하게 관리됩니다."
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .brownishGray
            $0.setLineHeight(lineHeight: 20)
            makeTableFooter.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(infoLabel.snp.bottom).offset(6)
                m.left.equalToSuperview().offset(16)
                m.right.equalToSuperview().inset(16)
            }
        }
        
        tableView.tableFooterView = makeTableFooter
    }
    
    private func didChangeContentView(_ isHaveCert: Bool) {
        if isHaveCert {
            certContentView.isHidden = false
            emptyContentView.isHidden = true
        } else {
            certContentView.isHidden = true
            emptyContentView.isHidden = false
        }
    }
    
}

// MARK: - Layout

extension SelectCertificateViewController {
    
    private func layout() {
        emptyContentView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        emptyContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        emptyContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        emptyContentView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        
        certContentView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        certContentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        certContentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        certContentView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true

        certContentViewLayout()
        emptyContentViewLayout()
    }
    
    private func certContentViewLayout() {
        certTitleLabel.topAnchor.constraint(equalTo: certContentView.topAnchor, constant: 36).isActive = true
        certTitleLabel.leadingAnchor.constraint(equalTo: certContentView.leadingAnchor, constant: 18).isActive = true
        certTitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        tableView.leadingAnchor.constraint(equalTo: certContentView.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: certContentView.trailingAnchor, constant: -16).isActive = true
        tableView.topAnchor.constraint(equalTo: certTitleLabel.bottomAnchor, constant: 10).isActive = true
        tableViewHeight = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeight.isActive = true
        
        importCertButtonWhenHave.topAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 20).isActive = true
        importCertButtonWhenHave.centerXAnchor.constraint(equalTo: certContentView.centerXAnchor).isActive = true
        importCertButtonWhenHave.bottomAnchor.constraint(equalTo: certContentView.bottomAnchor, constant: -56).isActive = true
        importCertButtonWhenHave.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    private func emptyContentViewLayout() {
        centerImage.centerYAnchor.constraint(equalTo: emptyContentView.centerYAnchor, constant: -110.5).isActive = true
        centerImage.centerXAnchor.constraint(equalTo: emptyContentView.centerXAnchor).isActive = true
        centerImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        centerImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        descLabel1.topAnchor.constraint(equalTo: centerImage.bottomAnchor, constant: 8).isActive = true
        descLabel1.centerXAnchor.constraint(equalTo: centerImage.centerXAnchor).isActive = true
        descLabel1.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        descLabel2.topAnchor.constraint(equalTo: descLabel1.bottomAnchor, constant: 8).isActive = true
        descLabel2.centerXAnchor.constraint(equalTo: descLabel1.centerXAnchor).isActive = true
        descLabel2.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        importCertButtonWhenNotHave.topAnchor.constraint(greaterThanOrEqualTo: descLabel2.bottomAnchor, constant: 20).isActive = true
        importCertButtonWhenNotHave.bottomAnchor.constraint(greaterThanOrEqualTo: emptyContentView.bottomAnchor, constant: -16).isActive = true
        importCertButtonWhenNotHave.leadingAnchor.constraint(equalTo: emptyContentView.leadingAnchor, constant: 16).isActive = true
        importCertButtonWhenNotHave.trailingAnchor.constraint(equalTo: emptyContentView.trailingAnchor, constant: -16).isActive = true
        importCertButtonWhenNotHave.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
    
}

// MARK: - DataSource

extension SelectCertificateViewController {
    private func dataSource() -> RxTableViewSectionedReloadDataSource<CertificateSection> {
        return RxTableViewSectionedReloadDataSource<CertificateSection>(configureCell: { [weak self] (_, tv, ip, item) in
            guard self != nil else {return UITableViewCell()}
            
            switch item {
            case .cert(let certInfo):
                let cell = tv.dequeueReusableCell(for: ip, cellType: CertificateTableViewCell.self)
                
                cell.configure(with: certInfo)
                return cell
            }
        })
    }
}
