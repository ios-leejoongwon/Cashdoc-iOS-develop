//
//  EtcDetailViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/09.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

final class EtcDetailViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private let data: EtcPropertyList
    
    // MARK: - UI Components
    
    private weak var nickNameLabel: UILabel!
    private weak var balanceLabel: UILabel!
    private weak var middleLine: UIImageView!
    private weak var memoTitle: UILabel!
    private weak var memoLabel: UILabel!
    private weak var editButton: UIButton!
    private weak var removeButton: UIButton!
    
    // MARK: - Con(De)structor
    
    init(data: EtcPropertyList) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        setProperties()
        bindView(with: data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configure()
    }
    
    // MARK: - Binding
    
    private func bindView(with data: EtcPropertyList) {
        editButton.rx.tap
            .map { data }
            .bind { (model) in
                let vc = EtcAddViewController(data: model)
                GlobalFunction.pushVC(vc, animated: true)
        }.disposed(by: disposeBag)
        removeButton.rx.tap
            .map { data.id }
            .bind { [weak self] (id) in
                guard let self = self else { return }
                GlobalFunction.getAlertController(vc: self,
                                                  title: "삭제",
                                                  message: "선택하신 기타 자산 내역이 삭제됩니다.\n정말 삭제하시겠습니까?")
                    .bind(onNext: { (isOk) in
                        guard isOk else { return }
                        EtcPropertyRealmProxy().delete(id: id)
                        GlobalFunction.CDPopToRootViewController(animated: true)
                    })
                    .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    // MARK: - Private
    
    private func configure() {
        nickNameLabel.text = data.nickName
        balanceLabel.text = String(format: "%@원", data.balance.commaValue)
        memoLabel.text = data.memo
    }
    
    private func setProperties() {
        view.backgroundColor = .white
        title = "기타 자산 상세"
        
        middleLine = UIImageView().then {
            $0.backgroundColor = .grayTwoCw
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalToSuperview().inset(122)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(8)
            }
        }
        nickNameLabel = UILabel().then {
            $0.setFontToMedium(ofSize: 14)
            $0.setLineHeight(lineHeight: 20)
            $0.textColor = .blackCw
            view.addSubview($0)
            $0.snp.makeConstraints {(make) in
                make.top.equalToSuperview().inset(16)
                make.leading.equalToSuperview().inset(24)
                make.trailing.lessThanOrEqualToSuperview().inset(24)
            }
        }
        balanceLabel = UILabel().then {
            $0.setFontToMedium(ofSize: 24)
            $0.setLineHeight(lineHeight: 28)
            $0.textAlignment = .right
            $0.textColor = .blackCw
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.bottom.equalTo(middleLine.snp.top).offset(-23.2)
                make.trailing.equalToSuperview().inset(24)
                make.leading.lessThanOrEqualToSuperview().inset(24)
            }
        }
        memoTitle = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.setLineHeight(lineHeight: 20)
            $0.textColor = .brownGrayCw
            $0.text = "메모"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(middleLine.snp.bottom).offset(36)
                make.leading.equalToSuperview().inset(24)
            }
        }
        memoLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.setLineHeight(lineHeight: 20)
            $0.textColor = .blackCw
            $0.numberOfLines = 0
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(memoTitle)
                make.leading.equalTo(memoTitle).offset(74)
                make.trailing.lessThanOrEqualToSuperview().inset(24)
            }
        }
        editButton = UIButton().then {
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.grayCw.cgColor
            $0.setBackgroundColor(.white, forState: .normal)
            $0.setTitle("편집", for: .normal)
            $0.setTitleColor(.brownishGrayCw, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14)
            $0.titleLabel?.textAlignment = .center
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().inset(16)
                make.height.equalTo(42)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            }
        }
        removeButton = UIButton().then {
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.redCw.cgColor
            $0.setBackgroundColor(.white, forState: .normal)
            $0.setTitle("삭제", for: .normal)
            $0.setTitleColor(.brownishGrayCw, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14)
            $0.titleLabel?.textAlignment = .center
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.leading.equalTo(editButton.snp.trailing).offset(7)
                make.trailing.equalToSuperview().inset(16)
                make.size.equalTo(editButton)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            }
        }
    }
}
