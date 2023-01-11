//
//  LottoPopupVC.swift
//  Cashdoc
//
//  Created by bzjoowan on 2021/05/03.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Foundation
import SwiftyJSON

class LottoPopupVC: CashdocViewController {
    @IBOutlet weak var lottoTitleLabel: UILabel!
    @IBOutlet weak var lottoHaveLabel: UILabel!
    @IBOutlet weak var lottoNextLabel: UILabel!
    @IBOutlet weak var lottoBallView01: UIView!
    @IBOutlet weak var lottoBallView02: UIView!
    @IBOutlet weak var lottoBallView03: UIView!
    @IBOutlet weak var lottoBallView04: UIView!
    @IBOutlet weak var lottoBallView05: UIView!
    @IBOutlet weak var lottoBallView06: UIView!
    @IBOutlet weak var lottoFailImageView: UIImageView!
    
    var getModel = LottoApplyModel(JSON.null)
    var isToday = false
    var errorCode = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if errorCode == 0 {
            if isToday {
                lottoTitleLabel.text = "오늘의 로또가 발급되었어요."
            } else {
                lottoTitleLabel.text = "\(getModel.roundNumber)회 캐시로또가 발급되었어요."
            }
            lottoHaveLabel.attributedText = GlobalFunction.stringToAttriColor("보유한 캐시로또 \(getModel.roundCoupons)장으로\n1등 1천만 캐시의 행운을 기대하세요!", wantText: "\(getModel.roundCoupons)", textColor: UIColor.blueCw, lineHeight: 24)
            lottoNextLabel.text = "\(getModel.roundNumber)회 당첨자 발표는 \(dateToString(getModel.raffleDate, formatS: "EEEE"))\n\(dateToString(getModel.raffleDate, formatS: "a h시 mm분"))에 진행될 예정입니다."
            self.drawLottoBalls()
        } else {
            lottoTitleLabel.isHidden = true
            lottoNextLabel.text = "당첨자 발표는 매주 진행됩니다."
            if errorCode == 610 {
                lottoFailImageView.image = UIImage(named: "imgCharacterRottoSmall01")
                lottoHaveLabel.text = "다음에는 꼭 자정이 되기 전에\n캐시로또를 발급 받아주세요."
            } else if errorCode == 612 {
                lottoFailImageView.image = UIImage(named: "imgCharacterRottoSmall01")
                lottoHaveLabel.text = "다시 시도해 주세요."
            } else {
                lottoFailImageView.image = UIImage(named: "imgCharacterRottoSmall01")
                lottoHaveLabel.text = "이미 캐시로또를 발급 받으셨어요.\n내일 참여해주세요."
            }
        }
        
        GlobalDefine.shared.mainHome?.appearWithLotto = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GlobalDefine.shared.curNav?.setNavigationBarHidden(true, animated: animated)
    }
    
    func dateToString(_ date: Date, formatS: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = formatS
//        formatter.amSymbol = "오전"
//        formatter.pmSymbol = "오후"
        return formatter.string(from: date)
    }
    
    func drawLottoBalls() {
        let numbers = getModel.lottoNumber.sorted()
        let ballViews = [lottoBallView01, lottoBallView02, lottoBallView03, lottoBallView04, lottoBallView05, lottoBallView06]
        
        for i in 0...5 {
            let number = numbers[safe: i] ?? 0
            let ballView = ballViews[safe: i] ?? lottoBallView01
            ballView?.clipsToBounds = true
            
            let makeImageView = UIImageView()
            makeImageView.clipsToBounds = true
            ballView?.addSubview(makeImageView)
            makeImageView.snp.makeConstraints { m in
                m.edges.equalToSuperview()
            }
            
            let makeView = UIView()
            makeView.clipsToBounds = true
            makeView.layer.cornerRadius = 14.5
            makeView.backgroundColor = .white
        
            ballView?.addSubview(makeView)
            makeView.snp.makeConstraints { m in
                m.size.equalTo(29)
                m.center.equalToSuperview()
            }
            
            _ = UIImageView().then {
                $0.image = UIImage(named: "imgBallIn")
                makeView.addSubview($0)
                $0.snp.makeConstraints { m in
                    m.edges.equalToSuperview()
                }
            }
            
            _ = UILabel().then {
                $0.text = "\(number)"
                $0.font = .boldSystemFont(ofSize: 16)
                makeView.addSubview($0)
                $0.snp.makeConstraints { m in
                    m.center.equalToSuperview()
                }
            }
            
            _ = UIView().then {
                $0.backgroundColor = .white
                $0.frame = ballView!.bounds
                ballView?.addSubview($0)

                let maskLayer = CAShapeLayer()
                maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
                let bezierPAth = UIBezierPath(rect: $0.bounds)
                bezierPAth.append(UIBezierPath(roundedRect: $0.bounds, cornerRadius: 23))
                maskLayer.backgroundColor = UIColor.blue.cgColor
                maskLayer.path = bezierPAth.cgPath
                $0.layer.mask = maskLayer
            }
            
            switch number {
            case 1...10:
                makeImageView.image = UIImage(named: "imgBallYellow")
            case 11...20:
                makeImageView.image = UIImage(named: "imgBallBlue")
            case 21...30:
                makeImageView.image = UIImage(named: "imgBallPink")
            case 31...40:
                makeImageView.image = UIImage(named: "imgBallGray")
            case 41...45:
                makeImageView.image = UIImage(named: "imgBallGreen")
            default:
                makeImageView.image = UIImage(named: "imgBallYellow")
            }
            
            self.rotationBall(makeView)
        }
    }
    
    func rotationBall(_ getView: UIView) {
        var rotationAnimation = CABasicAnimation()
        rotationAnimation = CABasicAnimation.init(keyPath: "position.x")
        rotationAnimation.fromValue = -40
        rotationAnimation.toValue = 60
        rotationAnimation.duration = 0.6
        rotationAnimation.fillMode = CAMediaTimingFillMode.forwards
        rotationAnimation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeOut)
        rotationAnimation.repeatCount = 4.5
        getView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    @IBAction func closeAct() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showMyLotto() {
        self.navigationController?.popViewController(animated: false)
        GlobalFunction.pushToWebViewController(title: "캐시로또", url: API.LOTTO_INVENTORY_URL + "?tab=2", hiddenbar: true)
    }
}
