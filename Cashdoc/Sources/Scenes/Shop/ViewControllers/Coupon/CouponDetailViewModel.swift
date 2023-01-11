//
//  CouponDetailViewModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class CouponDetailViewModel {
    
    private var disposeBag = DisposeBag()
    
}

// MARK: - ViewModelType

extension CouponDetailViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<CouponModel>
        let barcodeNumberCopyTrigger: Driver<CouponModel>
    }
    struct Output {
        let title: Driver<String>
        let affiliate: Driver<String>
        let expiredAt: Driver<String>
        let imageUrl: Driver<URL>
        let description: Driver<String>
        let barcodeImage: Driver<UIImage>
        let barcodeNo: Driver<String>
        let isBarcodeHold: Driver<Bool>
        let barcodeCoverText: Driver<NSAttributedString>
        let barcodeNumberCopy: Driver<String>
    }
    
    // MARK: - Internal methods
    
    func transform(input: Input) -> Output {
        let titleRelay: PublishRelay<String> = .init()
        let affiliateRelay: PublishRelay<String> = .init()
        let expiredAtRelay: PublishRelay<String> = .init()
        let imageUrlRelay: PublishRelay<URL> = .init()
        let descriptionRelay: PublishRelay<String> = .init()
        let barcodeImageRelay: PublishRelay<UIImage> = .init()
        let barcodeNoRelay: PublishRelay<String> = .init()
        let isBarcodeHoldRelay: PublishRelay<Bool> = .init()
        let barcodeCoverTextRelay: PublishRelay<NSAttributedString> = .init()
        let barcodeNumberCopyRelay: PublishRelay<String> = .init()
        
        input.trigger
            .drive(onNext: { [weak self] (coupon) in
                guard let self = self else {return}
                
                if let title = coupon.title {
                    titleRelay.accept(title)
                }
                
                if let affiliate = coupon.affiliate {
                    affiliateRelay.accept(affiliate)
                }
                
                if let expiredAt = self.getConvertExpiredAt(expiredAt: coupon.expiredAt) {
                    expiredAtRelay.accept(expiredAt)
                }
                
                if let imageUrlString = coupon.imageUrl, let imageUrl = URL(string: imageUrlString) {
                    imageUrlRelay.accept(imageUrl)
                }
                
                if let description = coupon.description {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = SERVER_DATE_FORMAT
                    
                    if let active = coupon.active,
                        let activeDate = dateFormatter.date(from: active),
                        let delay = coupon.delay {
                        
                        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: Date(), to: activeDate)
                        if let hour = components.hour,
                            let minute = components.minute,
                            let second = components.second,
                            hour >= 0,
                            minute >= 0,
                            second >= 0 {
                            
                            let text = "해당 상품은 구매 \(delay)시간 후에 사용하실 수 있습니다.\n지금부터 \(hour)시 \(minute)분 \(second)초 후에 사용 가능합니다."
                            descriptionRelay.accept(text)
                        } else {
                            descriptionRelay.accept(description)
                        }
                    } else {
                        descriptionRelay.accept(description)
                    }
                }
                
                if let barcodeImage = self.getBarcodeImage(pinNo: coupon.pinNo) {
                    barcodeImageRelay.accept(barcodeImage)
                }
                
                if let barcodeNo = coupon.pinNo {
                    barcodeNoRelay.accept(barcodeNo)
                }
                
                if let delay = coupon.delay, delay > 0 {
                    if let coverText = self.getCoverAttributeString(delay: delay) {
                        barcodeCoverTextRelay.accept(coverText)
                    }
                    isBarcodeHoldRelay.accept(false)
                }
            })
            .disposed(by: disposeBag)
        input.barcodeNumberCopyTrigger
            .drive(onNext: { (coupon) in
                guard let pinNo = coupon.pinNo else {return}
                
                let pinNoWithRemovedHyphen = pinNo.replacingOccurrences(of: "-", with: "")
                barcodeNumberCopyRelay.accept(pinNoWithRemovedHyphen)
            })
            .disposed(by: disposeBag)
        
        return Output(title: titleRelay.asDriverOnErrorJustNever(),
                      affiliate: affiliateRelay.asDriverOnErrorJustNever(),
                      expiredAt: expiredAtRelay.asDriverOnErrorJustNever(),
                      imageUrl: imageUrlRelay.asDriverOnErrorJustNever(),
                      description: descriptionRelay.asDriverOnErrorJustNever(),
                      barcodeImage: barcodeImageRelay.asDriverOnErrorJustNever(),
                      barcodeNo: barcodeNoRelay.asDriverOnErrorJustNever(),
                      isBarcodeHold: isBarcodeHoldRelay.asDriverOnErrorJustNever(),
                      barcodeCoverText: barcodeCoverTextRelay.asDriverOnErrorJustNever(),
                      barcodeNumberCopy: barcodeNumberCopyRelay.asDriverOnErrorJustNever())
    }
    
    // MARK: - Private methods
    
    private func getBarcodeImage(pinNo: String?) -> UIImage? {
        guard let barcodeNo = pinNo, let filter = CIFilter(name: "CICode128BarcodeGenerator") else {return nil}
        let data = barcodeNo.data(using: .ascii)
        filter.setValue(data, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else {return nil}
        outputImage.transformed(by: CGAffineTransform(scaleX: 3, y: 3))
        return UIImage(ciImage: outputImage)
    }
    
    private func getConvertExpiredAt(expiredAt: Int?) -> String? {
        guard let expiredAt = expiredAt else {return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let date = Date(timeIntervalSince1970: TimeInterval(expiredAt))
        let convertDate = dateFormatter.string(from: date)
        return "\(convertDate)까지"
    }
    
    private func getCoverAttributeString(delay: Int) -> NSAttributedString? {
        let coverText = "상품 번호는 구매 후 \(delay)시간 뒤에 나타납니다."
        let blueText = "구매 후 \(delay)시간 뒤"
        
        guard let nsRange = coverText.nsRange(of: blueText) else {return nil}
        
        let attributeString = NSMutableAttributedString(string: coverText)
        attributeString.addAttribute(.foregroundColor, value: UIColor.azureBlue, range: nsRange)
        return attributeString
    }
    
}
