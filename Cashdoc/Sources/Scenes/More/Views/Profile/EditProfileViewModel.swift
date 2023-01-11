//
//  EditProfileViewModel.swift
//  Cashdoc
//
//  Created by Cashwalk on 2022/04/25.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

final class EditProfileViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    static let maxLength = 20
    
    struct Input {
        let name: Observable<String>
        let editPhotoTrigger: Driver<Void>
    }
    
    struct Output {
        let nameCount: Observable<String>
        let guide: Observable<String>
        let imageName: PublishSubject<UIImage>
        let amendButton: Observable<Bool>
        let isChangeBaseImg: Observable<Bool>
    }
    
    private let nameText = BehaviorRelay<String>(value: "")
    
    func transform(input: Input) -> Output {
        input.name
            .bind(to: nameText)
            .disposed(by: disposeBag)
        
        input.editPhotoTrigger
            .drive(onNext: {
                GlobalFunction.CDActionSheet("첨부파일 선택", leftItems: ["사진첩에서 가져오기", "기본 이미지로 변경"]) { (idx, _) in
                    switch idx {
                    case 0:
                        GlobalFunction.presentVC(PhotoUpdateViewController(), animated: true)
                    case 1:
                        PhotoUpdatePopupViewModel().changeBasicImage()
                    default:
                        return
                    }
                    
                }
            }).disposed(by: disposeBag)
            
        let nameCount = nameText.map { self.count(name: $0) }.asObservable()
        let guide = nameText.map { self.notice($0) }.asObservable()
        let isEnabled = nameText.map { self.check(name: $0) }.asObservable()
        let imageName = PhotoUpdatePopupViewModel.imageName
        let isChangeBaseImg = PhotoUpdatePopupViewModel.isChangeBasicImage
            
        return Output(nameCount: nameCount,
                      guide: guide,
                      imageName: imageName,
                      amendButton: isEnabled,
                      isChangeBaseImg: isChangeBaseImg)
    }
    
    private func check(name: String) -> Bool {
        if name.count >= 2 && name.count <= EditProfileViewModel.maxLength {
            return true
        }
        return false
    }
    
    private func count(name: String) -> String {
        return "\(String(name.count))/\(EditProfileViewModel.maxLength)"
    }
    
    private func notice(_ name: String) -> String {
        if name.count == 1 {
            return "닉네임은 최소 2자 이상 입력해주세요."
        } else if name.count == 20 {
            return "닉네임은 \(EditProfileViewModel.maxLength)자까지 사용 가능합니다."
        } else {
            return ""
        }
    }
}
