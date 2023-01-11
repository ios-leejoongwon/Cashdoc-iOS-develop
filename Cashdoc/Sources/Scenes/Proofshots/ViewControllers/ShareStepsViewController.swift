//
//  ShareStepsVC.swift
//  Cashwalk
//
//  Created by lovelycat on 2020/11/13.
//  Copyright © 2020 Cashwalk, Inc. All rights reserved.
//

import Photos
import RxSwift
import CoreMotion
import Foundation

import KakaoSDKShare
import KakaoSDKCommon
import KakaoSDKTemplate
import KakaoSDKAuth
import KakaoSDKUser

enum SnsType {
    case Instagram
    case navercafe
}

final class ShareStepsViewController: CashdocViewController {

    // MARK: - Properties
    private var shareImage = UIImage()
    private var documentsDirectoryURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private var isImageSave: Bool = false
    private var isRightBarButtonItem: Bool = false // 저장하기 버튼으로 저장할때만 저장완료 메시지 띄워준다.

    // MARK: - UI Components

    private let rightBarButtonItem = UIBarButtonItem().then {
        $0.image = UIImage(named: "icPhotoDownBlack")
        $0.style = .plain
    }
    
    private let backBarButtonItem = UIBarButtonItem().then {
        $0.image = UIImage(named: "icArrow02StyleLeftBlack")
        $0.style = .plain
    }

    // Capture
    private let captureView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let captureImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentMode = .scaleAspectFit
    }

    // Bottom
    private let bottomView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let shareTextLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .systemFont(ofSize: 18, weight: .medium)
        $0.textColor = UIColor.fromRGB(46, 46, 46)
        $0.text = "공유하기"
    }
    private let stackView = UIStackView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.axis = .horizontal
            $0.alignment = .center
            $0.distribution = .equalSpacing
            $0.backgroundColor = .clear
        }

    private let shareInstagramButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "icSnsInsta"), for: .normal)
    }

    private let shareNaverCafeButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "ImgSnsNavercafe"), for: .normal)
    }

    private let shareKakaoBgButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "icSnsKakao"), for: .normal)
    }

    private let shareOtherButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(UIImage(named: "icSnsMore"), for: .normal)
    }

    private var isConnected: Bool {
        if ReachabilityManager.reachability.connection == .unavailable {
            return false
        } else {
            return true
        }
    }
    // MARK: - Overridden: BaseViewController

    override var navigationBarBarTintColorWhenDisappeared: UIColor? {
        return .sunFlowerYellowCw
    }

    override var backButtonTitleHidden: Bool {
        return true
    }

    // MARK: - Overridden: UIViewController
    init(captureImage: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.shareImage = captureImage
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setProperties()
        bindView()

        view.addSubview(captureView)
        captureView.addSubview(captureImageView)
        view.addSubview(bottomView)
        bottomView.addSubview(shareTextLabel)

        view.addSubview(stackView)
        stackView.addArrangedSubview(shareInstagramButton)
        stackView.addArrangedSubview(shareNaverCafeButton)
        stackView.addArrangedSubview(shareKakaoBgButton)
        stackView.addArrangedSubview(shareOtherButton)

        layout()
        captureImageView.image = shareImage

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.checkPHPhotoLibraryAuthorize() // iOS14이상에서 권한체크 먼저 안하면 선택사진만 허용 했을 경우 오류 발생
    }

    // MARK: - Binding

    private func bindView() {
    
        backBarButtonItem.rx.tap
            .bind { [weak self] (_) in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        rightBarButtonItem.rx.tap
            .bind { [weak self] (_) in
                guard let self = self else {return} // 저장
                guard let image = self.captureView.asImage() else {return}
                if self.isImageSave == false {
                    self.isRightBarButtonItem = true
                    self.writeToPhotoAlbum(image: image)
                } else {
                    GlobalDefine.shared.curNav?.view.makeToast("인증샷이 저장되었습니다.")
                }
            }
            .disposed(by: disposeBag)
        shareInstagramButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.checkPhotoAuthoriz(type: .Instagram)
            }
            .disposed(by: disposeBag)
        
        shareNaverCafeButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                
                self.checkPhotoAuthoriz(type: .navercafe)
            }
            .disposed(by: disposeBag)
        shareKakaoBgButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                if self.isConnected {

                    if !UserApi.isKakaoTalkLoginAvailable() { // 카카오톡 미설치
                        GlobalDefine.shared.curNav?.view.makeToast("카카오톡을 설치해주세요.")
                        return
                    }

                    guard let image = self.captureView.asImage() else {return}
                    let resizeImage = image.resizeImage(newWidth: self.view.frame.width)

                    self.showLoadingIndicator()

                    ShareApi.shared.imageUpload(image: resizeImage) { [weak self] (imageUploadResult, error) in
                        if let error = error {
                            print(error) // 업로드 실패
                                                        self?.hideLoadingIndicator()
                            GlobalDefine.shared.curNav?.view.makeToast("네트워크 오류로 인해 공유할 수 없습니다.")
                        } else {
                            print("imageUpload() success.:\(String(describing: imageUploadResult))")
                            guard let imgUrl = imageUploadResult?.infos.original.url else {
                                                                self?.hideLoadingIndicator()
                                GlobalDefine.shared.curNav?.view.makeToast("네트워크 오류로 인해 공유할 수 없습니다.")
                                return
                            }
                            let templateId = 78949
                            
                            // 템플릿 Arguments
                            let templateArgs = ["image": "\(imgUrl)"]
                            ShareApi.shared.shareCustom(templateId: Int64(templateId), templateArgs: templateArgs) { [weak self] (linkResult, error) in
                                if let error = error {
                                                                        self?.hideLoadingIndicator()
                                    Log.al(error)
                                    GlobalDefine.shared.curNav?.view.makeToast("네트워크 오류로 인해 공유할 수 없습니다.")
                                } else {
                                                                        self?.hideLoadingIndicator()
                                    Log.al("customLink() success.")
                                    GlobalFunction.FirLog(string: "인증샷_sns공유_카카오톡_클릭_iOS")
                                    if self?.isImageSave == false {
                                        self?.isRightBarButtonItem = false
                                        self?.writeToPhotoAlbum(image: image)
                                    }
                                    if let linkResult = linkResult {
                                        UIApplication.shared.open(linkResult.url, options: [:], completionHandler: nil)
                                    }
                                }
                            }
                        }
                    }
                } else {
                                        self.hideLoadingIndicator()
                    GlobalDefine.shared.curNav?.view.makeToast("네트워크 오류로 인해 공유할 수 없습니다.")
                }

            }
            .disposed(by: disposeBag)
        shareOtherButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return} 
                var objectToShare = [Any]()
                let image = self.captureView.asImage()
                if let image = image {
                    if self.isImageSave == false {
                        self.isRightBarButtonItem = false
                        self.writeToPhotoAlbum(image: image)
                    }
                    objectToShare.append(image)
                }
                
                GlobalFunction.FirLog(string: "인증샷_sns공유_더보기_클릭_iOS")
                let activityVC = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [.airDrop,
                                                    .addToReadingList,
                                                    .assignToContact,
                                                    .saveToCameraRoll,
                                                    .print,
                                                    .postToWeibo,
                                                    .copyToPasteboard,
                                                    .openInIBooks,
                                                    .postToFacebook]
                self.present(activityVC, animated: true, completion: nil)

            }
            .disposed(by: disposeBag)
    }

    // MARK: - Private methods

    private func setProperties() {
        title = "인증샷 공유"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.leftBarButtonItem = backBarButtonItem
    }

    private func checkPHPhotoLibraryAuthorize() {
        if #available(iOS 14, *) {
            let requiredAccessLevel: PHAccessLevel = .addOnly
            PHPhotoLibrary.requestAuthorization(for: requiredAccessLevel) { authorizationStatus in
                switch authorizationStatus {
                case .limited:
                    Log.al("11. limited authorization granted")
                case .authorized:
                    Log.al("12. authorization granted")
                default:
                    Log.al("13. Unimplemented")
                }
            }
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized:
                    break
                default:
                    break
                }
            })
        }

    }

    private func storeImageToDocumentDirectory(image: UIImage, fileName: String) -> URL? {
        guard let data = image.pngData() else {
            return nil
        }
        let fileURL = self.fileURLInDocumentDirectory(fileName)
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            return nil
        }
    }

    private func fileURLInDocumentDirectory(_ fileName: String) -> URL {
        return self.documentsDirectoryURL.appendingPathComponent(fileName)
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func showLoadingIndicator() {
        GlobalFunction.CDShowLogoLoadingView()
    }

    private func hideLoadingIndicator() {
        GlobalFunction.CDHideLogoLoadingView()
    }

    private func postImageInstagram(image: UIImage, result: ((Bool) -> Void)? = nil) {

        if self.isConnected {
            guard URL(string: "instagram://app") != nil else {
                if let result = result {
                    result(false)
                }
                return
            }
            do {
                GlobalFunction.FirLog(string: "인증샷_sns공유_인스타그램_클릭_iOS")
                self.showLoadingIndicator()
                var shareURL = ""
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    let assetID = request.placeholderForCreatedAsset?.localIdentifier ?? ""
                    shareURL = "instagram://library?LocalIdentifier=" + assetID

                }, completionHandler: {_, _ in
                    DispatchQueue.main.async {
                        self.hideLoadingIndicator()
                        if let urlForRedirect = URL(string: shareURL) {
                            UIApplication.shared.open(urlForRedirect as URL, options: [:], completionHandler: { success in
                                if !success {
                                    GlobalDefine.shared.curNav?.view.makeToast("인스타그램을 설치해주세요.")
                                }
                            })
                        } else {
                            GlobalDefine.shared.curNav?.view.makeToast("인스타그램을 설치해주세요.")
                        }
                    }
                })
            }
        } else {
            GlobalDefine.shared.curNav?.view.makeToast("네트워크 오류로 인해 공유할 수 없습니다.")
        }
    }

    private func checkPhotoAuthoriz(type: SnsType) {
        // 인스타그램 공유 시 앨범에 사진 저장 후 공유하기 때문에 권한 허용 안 되어 있으면 공유하지 못한다.
        if #available(iOS 14, *) {
            let accessLevel: PHAccessLevel = .addOnly
            let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: accessLevel)

            switch authorizationStatus {
            case .limited:
                guard let image = self.captureView.asImage() else {return}
                if type == .Instagram {
                    self.postImageInstagram(image: image)
                } else {
                    self.postImageNaverCafe(image: image)
                }
                
            case .authorized:
                guard let image = self.captureView.asImage() else {return}
                if type == .Instagram {
                    self.postImageInstagram(image: image)
                } else {
                    self.postImageNaverCafe(image: image)
                }
            default:
                self.alertAlbumAuthorized()
            }

        } else {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                guard let image = self.captureView.asImage() else {return}
                if type == .Instagram {
                    self.postImageInstagram(image: image)
                } else {
                    self.postImageNaverCafe(image: image)
                }
            case .notDetermined:
                self.alertAlbumAuthorized()
            case .restricted:
                self.alertAlbumAuthorized()
            case .denied:
                self.alertAlbumAuthorized()
            case .limited:
                guard let image = self.captureView.asImage() else {return}
                if type == .Instagram {
                    self.postImageInstagram(image: image)
                } else {
                    self.postImageNaverCafe(image: image)
                }
            @unknown default:
                self.alertAlbumAuthorized()
            }
        }
    }

    private func writeToPhotoAlbum(image: UIImage) {
        if #available(iOS 14, *) {
            let accessLevel: PHAccessLevel = .addOnly
            let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: accessLevel)

            switch authorizationStatus {
            case .limited:
                Log.al("선택")
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveError), nil) // 선택한 사진일 경우 전체 앨범에 저장하는 방법 뿐이 없음
            case .authorized:
                Log.al("모든사진")
                let customAlbum = CustomPhotoAlbum()
                customAlbum.delegate = self
                customAlbum.saveImage(image: image)
            default:
                Log.al("허용안함 ")
                self.alertAlbumAuthorized()
            }

        } else {
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                let customAlbum = CustomPhotoAlbum()
                customAlbum.delegate = self
                customAlbum.saveImage(image: image)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    switch status {
                    case .authorized:
                        let customAlbum = CustomPhotoAlbum()
                        customAlbum.delegate = self
                        customAlbum.saveImage(image: image)
                    default:
                        self.alertAlbumAuthorized()
                    }
                })

            case .restricted:
                self.alertAlbumAuthorized()
            case .denied:
                self.alertAlbumAuthorized()
            case .limited:
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveError), nil) // 선택한 사진일 경우 전체 앨범에 저장하는 방법 뿐이 없음
            @unknown default:
                break
            }
        }
    }

    private func alertAlbumAuthorized() {

        DispatchQueue.main.async {
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let confirmAction = UIAlertAction(title: "확인", style: .default) { (_) -> Void in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
            }
            self.alert(title: "", message: "사진 접근 권한이 없는 경우 인증샷 저장이 불가능합니다. 설정에서 사진 접근을 허용해주세요. ", preferredStyle: .alert, actions: [cancelAction, confirmAction], completion: nil)
            return
        }
    }

    @objc private func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error == nil {
            if self.isImageSave == false {
                if self.isRightBarButtonItem == true {
                    GlobalDefine.shared.curNav?.view.makeToast("인증샷이 저장되었습니다.")
                }
                self.isImageSave = true
            }
        }
    }
    
    private func postImageNaverCafe(image: UIImage) {
        do {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: nil)
        }
        
        GlobalFunction.FirLog(string: "인증샷_sns공유_네이버카페_클릭_iOS")
        let contents = "캐시닥 인증샷이 사진 앱에 저장되었어요.\n좌측 하단 카메라 버튼을 눌러서 인증샷을 게시글에 넣어보세요!"
        let cafeSchemeUrl = "navercafe://write?contents=\(contents)"
        let encodedStr = cafeSchemeUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        Log.al("encodedStr = \(encodedStr) ")
        if let url = URL(string: encodedStr) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil) 
            } else {
                GlobalDefine.shared.curNav?.view.makeToast("네이버카페를 설치해 주세요.")
            }
        } else {
            GlobalDefine.shared.curNav?.view.makeToast("네이버카페를 설치해 주세요.")
        }
    }
}

// MARK: - Layout

extension ShareStepsViewController {

    private func layout() {

        captureView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        captureView.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true

        captureImageView.topAnchor.constraint(equalTo: captureView.topAnchor).isActive = true
        captureImageView.leadingAnchor.constraint(equalTo: captureView.leadingAnchor).isActive = true
        captureImageView.trailingAnchor.constraint(equalTo: captureView.trailingAnchor).isActive = true
        captureImageView.bottomAnchor.constraint(equalTo: captureView.bottomAnchor).isActive = true

        bottomView.topAnchor.constraint(equalTo: captureView.bottomAnchor).isActive = true
        bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true

        layoutBottomView()

    }

    private func layoutBottomView() {

        shareTextLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 24).isActive = true
        shareTextLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 20).isActive = true

        stackView.topAnchor.constraint(equalTo: shareTextLabel.bottomAnchor, constant: 14).isActive = true
        stackView.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -20).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: 64).isActive = true

        shareInstagramButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        shareInstagramButton.heightAnchor.constraint(equalToConstant: 64).isActive = true

        shareNaverCafeButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        shareNaverCafeButton
            .heightAnchor.constraint(equalToConstant: 64).isActive = true

        shareKakaoBgButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        shareKakaoBgButton.heightAnchor.constraint(equalToConstant: 64).isActive = true

        shareOtherButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        shareOtherButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
    }
 
}

extension ShareStepsViewController: CustomPhotoAlbumDelegate {
    func savePhotoSuccess() {
        if self.isImageSave == false {
            if self.isRightBarButtonItem == true {
                GlobalDefine.shared.curNav?.view.makeToast("인증샷이 저장되었습니다.")
            }
            self.isImageSave = true
        }
    }
} 
 
