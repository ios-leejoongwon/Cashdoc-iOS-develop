//
//  PhotoUpdatePopupViewModel.swift
//  Cashdoc
//
//  Created by Cashwalk on 2022/05/02.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

final class PhotoUpdatePopupViewModel {
    var disposeBag = DisposeBag()
    
    static var imageName = PublishSubject<UIImage>()
    static var isChangeBasicImage = PublishSubject<Bool>()
    
    func changeBasicImage() {
        PhotoUpdatePopupViewModel.imageName.onNext(UIImage(named: "imgPerson")!)
        PhotoUpdatePopupViewModel.isChangeBasicImage.onNext(true)
    }
    
    func changeAlbumImage(image: UIImage) {
        PhotoUpdatePopupViewModel.imageName.onNext(image)
        PhotoUpdatePopupViewModel.isChangeBasicImage.onNext(false)
    }
}
