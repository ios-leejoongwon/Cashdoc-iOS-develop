//
//  ConsumeDateTableViewCell.swift
//  Cashdoc
//
//  Created by Taejune Jung on 09/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class ConsumeDateTableViewCell: UITableViewCell {
    
    // MARK: - UI Componenets
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
        $0.clipsToBounds = true
    }
    private let dateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 22)
        $0.textColor = .blackCw
    }
    private let dayLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    private let incomeLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .blueCw
    }
    private let outgoingLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    private let titleView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
    }
    private let borderView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.grayCw.cgColor
    }
    private let separateView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(containerView)
        containerView.addSubview(titleView)
        titleView.addSubview(borderView)
        titleView.addSubview(separateView)
        titleView.addSubview(dateLabel)
        titleView.addSubview(dayLabel)
        titleView.addSubview(incomeLabel)
        titleView.addSubview(outgoingLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Internal methods
    
    func configure(with item: ConsumeDateItem, isFilter: Bool, type: CategoryType?) {
        dateLabel.text = item.date
        dayLabel.text = item.day
        if isFilter {
            incomeLabel.text = ""
            switch type {
            case .수입, .기타:
                outgoingLabel.text = item.outgoing.commaValue + "원"
            case .지출:
                outgoingLabel.text = "-" + item.outgoing.commaValue + "원"
            default:
                break
            }
        } else {
            outgoingLabel.text = "-" + item.outgoing.commaValue + "원"
            incomeLabel.text = "+" + item.income.commaValue + "원"
        }
    }
    
    // MARK: - Private methods
    private func setProperties() {
        self.backgroundColor = .grayTwoCw
        self.selectionStyle = .none
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}

extension ConsumeDateTableViewCell {
    
    private func layout() {
        
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        titleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8).isActive = true
        titleView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        titleView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        dateLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 13).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -13).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 20).isActive = true
        
        dayLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
        dayLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 4).isActive = true
        
        incomeLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        incomeLabel.leadingAnchor.constraint(greaterThanOrEqualTo: dayLabel.trailingAnchor, constant: 16).isActive = true
        incomeLabel.trailingAnchor.constraint(equalTo: outgoingLabel.leadingAnchor, constant: -12.7).isActive = true
        incomeLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        outgoingLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        outgoingLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -20.2).isActive = true
        outgoingLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        borderView.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        borderView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        borderView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        borderView.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        separateView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        separateView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        separateView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
}
