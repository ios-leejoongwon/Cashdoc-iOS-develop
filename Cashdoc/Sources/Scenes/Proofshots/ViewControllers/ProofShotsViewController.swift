//
//  ProofShotsVC.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/06/14.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
import Photos
import RxSwift
import CoreMotion
import Accelerate
import CoreImage

// swiftlint:disable file_length
class ProofShotsViewController: CashdocViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Properties
    
    private var biasValue: Float = 0.0
    private var isToday: Bool {
        return today.isSameDay(date: currentDay)
    }
    private var isFlashOnOff: Bool = false
    var dateData: (Date)? {
        didSet {
            guard let dateData = dateData else {return}
            let month = String(format: "%02d", dateData.month)
            let day = String(format: "%02d", dateData.day)
            let dateString = "\(month)월 \(day)일"
            dateLabel.text = dateString
            
            if isToday { // 오른쪽 버튼 비활성화
                arrowLeftButton.isEnabled = true
                arrowRightButton.isEnabled = false
            } else {
                let calendar = Calendar(identifier: .gregorian)
                let offsetComps = calendar.dateComponents([.year, .month, .day], from: currentDay, to: today)
                if case let (d?) = (offsetComps.day) {
                    if d >= 7 { // 왼쪽 버튼 비활성화
                        arrowLeftButton.isEnabled = false
                        arrowRightButton.isEnabled = true
                    } else {
                        arrowLeftButton.isEnabled = true
                        arrowRightButton.isEnabled = true
                    }
                }
            }
        }
    }
    private var cameraTemplateScrollViewBottom: Constraint!
    private var galleryTemplateScrollViewBottom: Constraint!
    private var originalGalleryImage: UIImage?
    private var documentsDirectoryURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    private var today: Date = Calendar.current.startOfDay(for: Date())
    private var currentDay: Date = Calendar.current.startOfDay(for: Date())
    private var isDarkMode: Bool = false
    
    // MARK: - UI Components
    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private let pickerController = UIImagePickerController()
    private var scrollView: UIScrollView!
    private var contentsView: UIView!
    private var cameraView: UIView!
    private var galleryView: UIView!
    private var backBarButtonItem: UIBarButtonItem!
    private var rightBarButtonItem: UIBarButtonItem!
    
    // 날짜 선택뷰
    private var topView: UIView!
    private var dateLabel: UILabel!
    private var arrowLeftButton: UIButton!
    private var arrowRightButton: UIButton!
    private var segmentedControl: CustomSegmentedControl!
    
    // 카메라
    private var cameraCaptureView: UIView!
    private var previewView: UIView! // 카메라의 뷰 파인더 역할
    private var captureImageView: UIImageView!
    private var cameraTemplateView: StepTemplateView!
    private var cameraDarkModeButton: UIButton!
    private var cameraSlider: UISlider!
    private var bottomView: UIView!
    private var cameraButton: UIButton!
    private var flipCameaButton: UIButton!
    private var flashOnButton: UIButton!
    private var darkmodeButton: UIButton!
    private var templateButton: UIButton!
    private var cameraTemplateScrollView: TemplateScrollView!
    
    // 갤러리
    private var galleryCaptureView: UIView!
    private var galleryImageView: UIImageView!
    private var galleryTemplateView: StepTemplateView!
    private var galleryDarkModeButton: UIButton!
    private var gallerySlider: UISlider!
    private var selectButton: UIButton? // 갤러리화면에서 선택한 버튼 정보
    private var galleryBottomView: UIView!
    private var galleryButton: UIButton!
    private var galleryDarkmodeButton: UIButton!
    private var galleryTemplateButton: UIButton!
    private var templateImgButton: UIButton!
    private var templateYellowButton: UIButton!
    private var templateGrayButton: UIButton!
    private var galleryTemplateScrollView: TemplateScrollView!
      
    // MARK: - Overridden: BaseViewController
    override var navigationBarBarTintColorWhenDisappeared: UIColor? {
        return .sunFlowerYellowCw
    }
    
    override var backButtonTitleHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        GlobalDefine.shared.isSeleteGalleryTap = false
        let myClientStep = GlobalDefine.shared.currentStep
        bindView()
        setGestureRecognizers()
        selectImgButton(button: self.templateImgButton)
        // 오늘날짜
        DispatchQueue.main.async {
            self.cameraTemplateView.startStepUpdates(step: myClientStep)
            self.galleryTemplateView.startStepUpdates(step: myClientStep)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        self.checkCameraAuthorized() // 고해상도

        // 플래시끄고 활성화처리 (공유화면에서 뒤로가기해서 다시 올 경우 재설정)
        self.isFlashOnOff = false
        self.flashOnButton.isSelected = false
        self.flashOnButton.isEnabled = true
        if GlobalDefine.shared.isSeleteGalleryTap { // 갤러리탭 선택 후 공유하기 화면에서 뒤로 왔을 때 갤러리탭 선택 되어 있게 설정
            DispatchQueue.main.async {
                self.segmentedControl.setIndex(index: 1)
                self.scrollToPage(page: 1, animated: false)
                self.selectImgButton(button: self.templateImgButton)
            }
        }
        guard let dateData = dateData else { return }
        DispatchQueue.main.async {
            self.cameraTemplateView.setStepsDateLabelText(dateData)
            self.galleryTemplateView.setStepsDateLabelText(dateData)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.captureSession != nil {
            self.captureSession.stopRunning()
            self.captureSession = nil
        }
    }

    deinit {
        GlobalDefine.shared.isSeleteGalleryTap = false
    }
    
    // MARK: - Overridden: BaseViewController - Protocol
    func setupView() {
        
        scrollView = UIScrollView().then {
            view.addSubview($0)
            $0.backgroundColor = UIColor.fromRGB(249, 249, 249)
            $0.isScrollEnabled = false
            $0.snp.makeConstraints {
                $0.edges.equalTo(0)
            }
        }
        backBarButtonItem = UIBarButtonItem().then {
            $0.image = UIImage(named: "icArrow02StyleLeftBlack")
            $0.style = .plain
        }
        rightBarButtonItem = UIBarButtonItem().then {
            $0.title = "완료"
            $0.style = .plain
        }
        _ = UIView().then {
            view.addSubview($0)
            $0.backgroundColor = UIColor.fromRGB(236, 236, 236)
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.top.equalTo(view.snp.top).offset(50)
                $0.height.equalTo(2)
            }
        }
        segmentedControl = CustomSegmentedControl(buttonTitles: ["사진 촬영", "갤러리"]).then {
            view.addSubview($0)
            $0.backgroundColor = .clear
            $0.textColor = .warmGrayCw
            $0.selectorTextColor = .blackCw
            $0.selectorViewColor = UIColor.fromRGB(46, 46, 46)
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.top.equalTo(view.snp.top)
                $0.height.equalTo(52)
            }
        }
        // 날짜 선택 뷰
        topView = UIView().then {
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.top.equalTo(segmentedControl.snp.bottom)
                $0.height.equalTo(50)
            }
        }
        dateLabel = UILabel().then {
            topView.addSubview($0)
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .blackThreeCw
            $0.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
        }
        arrowLeftButton = UIButton().then {
            topView.addSubview($0)
            $0.setImage(UIImage(named: "icArrowLeftGray"), for: .disabled)
            $0.setImage(UIImage(named: "icArrowLeftBlack"), for: .normal)
            $0.snp.makeConstraints {
                $0.centerY.leading.equalToSuperview()
                $0.width.height.equalTo(50)
            }
        }
        arrowRightButton = UIButton().then {
            topView.addSubview($0)
            $0.setImage(UIImage(named: "icArrowRightGray"), for: .disabled)
            $0.setImage(UIImage(named: "icArrowRightBlack"), for: .normal)
            $0.snp.makeConstraints {
                $0.centerY.trailing.equalToSuperview()
                $0.width.height.equalTo(50)
            }
        }
        // 컨텐츠뷰
        contentsView = UIView().then {
            scrollView.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalTo(0)
                let tempWidth = view.frame.width * 2
                $0.width.equalTo(tempWidth)
                $0.top.equalTo(topView.snp.bottom)
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
        }
        // 카메라
        cameraView = UIView().then {
            contentsView.addSubview($0)
            $0.snp.makeConstraints {
                $0.leading.top.bottom.equalTo(contentsView)
                $0.width.equalTo(view.frame.width)
            }
        }
        // 카메라캡쳐뷰
        cameraCaptureView = UIView().then {
            cameraView.addSubview($0)
            $0.backgroundColor = .black
            $0.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.height.equalTo(cameraView.snp.width)
            }
        }
        previewView = UIView().then {
            cameraCaptureView.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        // 사진을 찍은 후 캡쳐 이미지 (인증샷 공유하기 화면으로 전달할 캡쳐 이미지 hidden)
        captureImageView = UIImageView().then {
            cameraCaptureView.addSubview($0)
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalTo(cameraCaptureView)
            }
        }
        cameraTemplateView = StepTemplateView().then {
            cameraCaptureView.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        cameraDarkModeButton = UIButton().then {
            cameraCaptureView.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        cameraSlider = UISlider().then {
            cameraCaptureView.addSubview($0)
            $0.isHidden = true
            $0.minimumValue = -3
            $0.maximumValue = 3
            $0.tintColor = UIColor.fromRGBA(255, 210, 0, 0.3)
            $0.minimumTrackTintColor = UIColor.fromRGBA(255, 210, 0, 0.3)
            $0.maximumTrackTintColor = UIColor.fromRGBA(255, 210, 0, 0.3)
            $0.setValue(0, animated: false)
            $0.setThumbImage(UIImage(named: "icLightColor"), for: .normal)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(70)
                $0.width.equalTo(200)
                $0.height.equalTo(20)
            }
        }
        let tempRotationAngle = -CGFloat.pi / 2
        cameraSlider.transform = CGAffineTransform(rotationAngle: tempRotationAngle)
        
        // 카메라 버튼뷰
        bottomView = UIView().then {
            cameraView.addSubview($0)
            $0.backgroundColor = UIColor.fromRGB(249, 249, 249)
            $0.snp.makeConstraints {
                $0.height.equalTo(76)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
        let bottomStackView = UIStackView().then {
            bottomView.addSubview($0)
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.alignment = .center
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        flipCameaButton = UIButton().then {
            bottomStackView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "icDarkmodeSwitchCamera"), for: .normal)
            $0.setImage(UIImage(named: "icDarkmodeSwitchCamera"), for: .highlighted)
            $0.imageView?.contentMode = .scaleAspectFill
            $0.snp.makeConstraints {
                $0.width.height.equalTo(52)
            }
        }
        flashOnButton = UIButton().then {
            bottomStackView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "icDarkmodeFlash"), for: .normal)
            $0.setImage(UIImage(named: "icDarkmodeFlashFill"), for: .selected)
            $0.setImage(UIImage(named: "icFlashGray"), for: .disabled)
            $0.imageView?.contentMode = .scaleAspectFill
            $0.snp.makeConstraints {
                $0.width.height.equalTo(52)
            }
        }
        cameraButton = UIButton().then {
            bottomStackView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "ic60Shutter"), for: .normal)
            $0.imageView?.contentMode = .scaleAspectFill
            $0.snp.makeConstraints {
                $0.width.height.equalTo(60)
            }
        }
        darkmodeButton = UIButton().then {
            bottomStackView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "icDarkmodeBlack"), for: .normal)
            $0.setImage(UIImage(named: "icDarkmodeBlackFill"), for: .selected)
            $0.imageView?.contentMode = .scaleAspectFill
            $0.snp.makeConstraints {
                $0.width.height.equalTo(52)
            }
        }
        templateButton = UIButton().then {
            bottomStackView.addArrangedSubview($0)
            $0.setImage(UIImage(named: "icDarkmodeLayoutFill"), for: .normal)
            $0.setImage(UIImage(named: "icDarkmodeLayout"), for: .selected)
            $0.imageView?.contentMode = .scaleAspectFill
            $0.snp.makeConstraints {
                $0.width.height.equalTo(52)
            }
        }
        cameraTemplateScrollView = TemplateScrollView(isGalleryTap: false).then {
            cameraView.addSubview($0)
            $0.backgroundColor = UIColor.fromRGBA(255, 255, 255, 0.5)
            $0.snp.makeConstraints {
                $0.trailing.equalToSuperview()
                $0.height.equalTo(76)
                $0.leading.equalToSuperview()
                cameraTemplateScrollViewBottom = $0.bottom.equalTo(bottomView.snp.top).constraint
            }
        }
        cameraView.bringSubviewToFront(bottomView) // 카메라 버튼뷰를 앞으로 가져온다.
        // 갤러리
        galleryView = UIView().then {
            contentsView.addSubview($0)
            $0.snp.makeConstraints {
                $0.trailing.top.bottom.equalTo(contentsView)
                $0.width.equalTo(view.frame.width)
            }
        }
        galleryCaptureView = UIView().then {
            galleryView.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.height.equalTo(cameraView.snp.width)
            }
        }
        // 갤러리 기본배경 이미지
        galleryImageView = UIImageView().then {
            galleryCaptureView.addSubview($0)
            $0.image = UIImage(named: "templateImg")
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        self.originalGalleryImage = self.galleryImageView.image ?? UIImage(named: "templateImg")!
        galleryTemplateView = StepTemplateView().then {
            galleryCaptureView.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        galleryDarkModeButton = UIButton().then {
            galleryCaptureView.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        gallerySlider = UISlider().then {
            galleryCaptureView.addSubview($0)
            $0.isHidden = true
            $0.minimumValue = -0.5
            $0.maximumValue = 0.5
            $0.tintColor = UIColor.fromRGBA(255, 210, 0, 0.3)
            $0.minimumTrackTintColor = UIColor.fromRGBA(255, 210, 0, 0.3)
            $0.maximumTrackTintColor = UIColor.fromRGBA(255, 210, 0, 0.3)
            $0.setValue(0.0, animated: false)
            $0.setThumbImage(UIImage(named: "icLightColor"), for: .normal)
            $0.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.trailing.equalToSuperview().offset(70)
                $0.width.equalTo(200)
                $0.height.equalTo(20)
            }
        }
        gallerySlider.transform = CGAffineTransform(rotationAngle: tempRotationAngle)
        // 갤러리 버튼뷰
        galleryBottomView = UIView().then {
            galleryView.addSubview($0)
            $0.backgroundColor = UIColor.fromRGB(249, 249, 249)
            $0.snp.makeConstraints {
                $0.height.equalTo(76)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
        galleryButton = UIButton().then {
            galleryBottomView.addSubview($0)
            $0.setImage(UIImage(named: "icGalleryBlack"), for: .normal)
            $0.setImage(UIImage(named: "icGalleryBlack"), for: .highlighted)
            $0.imageView?.contentMode = .scaleAspectFill
            $0.snp.makeConstraints {
                $0.left.equalToSuperview().inset(10)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(24)
            }
        }
        galleryTemplateButton = UIButton().then {
            galleryBottomView.addSubview($0)
            $0.setImage(UIImage(named: "icDarkmodeLayoutFill"), for: .normal)
            $0.setImage(UIImage(named: "icDarkmodeLayout"), for: .selected)
            $0.imageView?.contentMode = .scaleAspectFill
            $0.snp.makeConstraints {
                $0.right.equalToSuperview().inset(10)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(24)
            }
        }
        galleryDarkmodeButton = UIButton().then {
            galleryBottomView.addSubview($0)
            $0.setImage(UIImage(named: "icDarkmodeBlack"), for: .normal)
            $0.setImage(UIImage(named: "icDarkmodeBlackFill"), for: .selected)
            $0.imageView?.contentMode = .scaleAspectFill
            $0.snp.makeConstraints {
                $0.right.equalTo(galleryTemplateButton.snp.left).offset(-43)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(24)
            }
        }
        templateImgButton = UIButton().then {
            galleryBottomView.addSubview($0)
            $0.setImage(UIImage(named: "templetButton"), for: .normal) 
            $0.imageView?.contentMode = .scaleAspectFill
            $0.IBcornerRadius = 12
            $0.tag = 1000
            $0.snp.makeConstraints {
                $0.leading.equalTo(galleryButton.snp.trailing).offset(30)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(24)
            }
        }
        templateYellowButton = UIButton().then {
            galleryBottomView.addSubview($0)
            $0.backgroundColor = .yellowCw
            $0.IBcornerRadius = 12
            $0.tag = 2000
            $0.snp.makeConstraints {
                $0.leading.equalTo(templateImgButton.snp.trailing).offset(30)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(24)
            }
        }
        templateGrayButton = UIButton().then {
            galleryBottomView.addSubview($0)
            $0.backgroundColor = .brownGrayCw
            $0.IBcornerRadius = 12
            $0.tag = 3000
            $0.snp.makeConstraints {
                $0.leading.equalTo(templateYellowButton.snp.trailing).offset(30)
                $0.centerY.equalToSuperview()
                $0.width.height.equalTo(24)
            }
        }
        galleryTemplateScrollView = TemplateScrollView(isGalleryTap: true).then {
            galleryView.addSubview($0)
            $0.backgroundColor = UIColor.fromRGBA(255, 255, 255, 0.5)
            $0.snp.makeConstraints {
                $0.height.equalTo(76)
                $0.trailing.equalToSuperview()
                $0.leading.equalToSuperview()
                galleryTemplateScrollViewBottom = $0.bottom.equalTo(galleryBottomView.snp.top).constraint
            }
        }
        galleryView.bringSubviewToFront(galleryBottomView) // 갤러리 버튼뷰를 앞으로 가져온다.
        _ = UIView().then { // 갤러리 템플릿 safeArea 영역 가리는 임시뷰
            galleryView.addSubview($0)
            $0.backgroundColor = UIColor.fromRGB(249, 249, 249)
            $0.snp.makeConstraints {
                $0.top.equalTo(galleryView.snp.bottom)
                $0.bottom.equalTo(view.snp.bottom)
                $0.leading.trailing.equalToSuperview()
            }
        }
    }
    
    func setupProperties() {
        title = "인증샷 선택"
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = backBarButtonItem
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = .photoLibrary
        self.segmentedControl.delegate = self
        dateData = self.currentDay
    }
    
    // MARK: - Binding
    private func bindView() {
        cameraTemplateScrollView.selecteTemplateType
            .bind { [weak self] type in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.cameraTemplateView.changeTemplateType(type: type)
                    self.galleryTemplateView.changeTemplateType(type: type)
                    self.cameraTemplateScrollView.selecteTemplate(type: type)
                    self.galleryTemplateScrollView.selecteTemplate(type: type)
                }
            }
            .disposed(by: disposeBag)
        galleryTemplateScrollView.selecteTemplateType
            .bind { [weak self] type in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.cameraTemplateView.changeTemplateType(type: type)
                    self.galleryTemplateView.changeTemplateType(type: type)
                    self.cameraTemplateScrollView.selecteTemplate(type: type)
                    self.galleryTemplateScrollView.selecteTemplate(type: type)
                }
            }
            .disposed(by: disposeBag)
        backBarButtonItem.rx.tap
            .bind { [weak self] (_) in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        rightBarButtonItem.rx.tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                // 갤러리 또는 기본 이미지 선택 시 인증샷 공유 화면으로 이동
                DispatchQueue.main.async {
                    guard let captureImage = self.galleryCaptureView.asImage() else {return}
                    let controller = ShareStepsViewController(captureImage: captureImage)
                    GlobalFunction.pushVC(controller, animated: true)
                }
            }
            .disposed(by: disposeBag)
        arrowLeftButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                // 오늘날짜와 비교 해서 7일까지만
                self.currentDay = Calendar.current.date(byAdding: .day, value: -1, to: self.currentDay)!
                self.dateData = self.currentDay
                self.cameraTemplateView.setStepsDateLabelText(self.currentDay)
                self.galleryTemplateView.setStepsDateLabelText(self.currentDay)
                self.getDaySteps()
            }
            .disposed(by: disposeBag)
        arrowRightButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                let newCurrentDay = Calendar.current.date(byAdding: .day, value: +1, to: self.currentDay)!
                self.currentDay = self.today <= newCurrentDay ? self.today : newCurrentDay
                self.dateData = self.currentDay
                self.cameraTemplateView.setStepsDateLabelText(self.currentDay)
                self.galleryTemplateView.setStepsDateLabelText(self.currentDay)
                self.getDaySteps()
            }
            .disposed(by: disposeBag)
        cameraButton.rx.tap
//            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.didTakePhoto()
            }
            .disposed(by: disposeBag)
        flipCameaButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.switchCamera()
            }
            .disposed(by: disposeBag)
        flashOnButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.toggleflash(on: true)
            }
            .disposed(by: disposeBag)
        darkmodeButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.darkmodeButton.isSelected.toggle()
                self.galleryDarkmodeButton.isSelected.toggle()
                self.isDarkMode = !self.isDarkMode
                self.cameraTemplateView.changeDarkMode(self.isDarkMode)
                self.galleryTemplateView.changeDarkMode(self.isDarkMode)
            }
            .disposed(by: disposeBag)
        cameraDarkModeButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.darkmodeButton.isSelected.toggle()
                self.galleryDarkmodeButton.isSelected.toggle()
                self.isDarkMode = !self.isDarkMode
                self.cameraTemplateView.changeDarkMode(self.isDarkMode)
                self.galleryTemplateView.changeDarkMode(self.isDarkMode)
            }
            .disposed(by: disposeBag)
        galleryDarkmodeButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.darkmodeButton.isSelected.toggle()
                self.galleryDarkmodeButton.isSelected.toggle()
                self.isDarkMode = !self.isDarkMode
                self.cameraTemplateView.changeDarkMode(self.isDarkMode)
                self.galleryTemplateView.changeDarkMode(self.isDarkMode)
            }
            .disposed(by: disposeBag)
        galleryDarkModeButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.darkmodeButton.isSelected.toggle()
                self.galleryDarkmodeButton.isSelected.toggle()
                self.isDarkMode = !self.isDarkMode
                self.cameraTemplateView.changeDarkMode(self.isDarkMode)
                self.galleryTemplateView.changeDarkMode(self.isDarkMode)
            }
            .disposed(by: disposeBag)
        templateButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.templateButton.isSelected.toggle()
                self.showCameraTemplateScrollView(isShow: !self.templateButton.isSelected)
                
            }
            .disposed(by: disposeBag)
        galleryTemplateButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.galleryTemplateButton.isSelected.toggle()
                self.showGalleryTemplateScrollView(isShow: !self.galleryTemplateButton.isSelected)
                
            }
            .disposed(by: disposeBag)
        galleryButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.showGallery()
            }
            .disposed(by: disposeBag)
        NotificationCenter.default.rx
            .notification(UIApplication.willEnterForegroundNotification)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else {return}
                if !self.isToday {
                    self.getDaySteps()
                }
            })
            .disposed(by: disposeBag)
        templateImgButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.selectImgButton(button: self.templateImgButton)
                self.galleryImageView.image = UIImage(named: "templateImg")
                self.originalGalleryImage = self.galleryImageView.image
            }
            .disposed(by: disposeBag)
        templateYellowButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.selectImgButton(button: self.templateYellowButton)
                self.galleryImageView.image = UIImage().withColor(.yellowCw) 
                self.originalGalleryImage = self.galleryImageView.image
            }
            .disposed(by: disposeBag)
        templateGrayButton.rx
            .tap
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.selectImgButton(button: self.templateGrayButton)
                self.galleryImageView.image = UIImage().withColor(.brownGrayCw)
                self.originalGalleryImage = self.galleryImageView.image
            }
            .disposed(by: disposeBag)
    }
    
    private func showLoadingIndicator() {
        GlobalFunction.CDShowLogoLoadingView()
    }

    private func hideLoadingIndicator() {
        GlobalFunction.CDHideLogoLoadingView()
    }
    
    private func showCameraTemplateScrollView(isShow: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            if isShow {
                self.cameraTemplateScrollViewBottom.update(offset: 0)
            } else {
                self.cameraTemplateScrollViewBottom.update(offset: 76)
            }
            self.view.layoutIfNeeded()
            }, completion: { (_) in
        })
    }
    
    private func showGalleryTemplateScrollView(isShow: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            if isShow {
                self.galleryTemplateScrollViewBottom.update(offset: 0)
            } else {
                self.galleryTemplateScrollViewBottom.update(offset: 76)
            }
            self.view.layoutIfNeeded()
            }, completion: { (_) in
        })
    }
    
    // MARK: - Private methods
    
    private func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        for device in deviceDescoverySession.devices where device.position == position {
            return device
        }
        return nil
    }
    
    private func checkAlertCameraAuthorized() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .notDetermined, .restricted, .denied:
            self.alertCameraAuthorized()
        case .authorized:
            Log.al("authorized")
        @unknown default:
            self.alertCameraAuthorized()
        }
    }
    
    private func checkCameraAuthorized() {
        showLoadingIndicator()
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
            self.cameraAuthorized()
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    self.cameraAuthorized()
                } else {
                    self.alertCameraAuthorized()
                    self.hideLoadingIndicator()
                }
            })
        }
    }
    
    private func cameraAuthorized() {
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) // 후면카메라 사용
        else {
            hideLoadingIndicator()
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        } catch {
            hideLoadingIndicator()
        }
        DispatchQueue.global(qos: .userInitiated).async { // [weak self] in
            self.captureSession.startRunning()
            DispatchQueue.main.async {
                self.hideLoadingIndicator()
            }
        }
    }
    
    private func alertCameraAuthorized() {
        DispatchQueue.main.async {
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (_) -> Void in
                self.hideLoadingIndicator()
                GlobalDefine.shared.isSeleteGalleryTap = true
                self.segmentedControl.setIndex(index: 1)
                self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                self.showDefaultPhoto()
            }
            let confirmAction = UIAlertAction(title: "확인", style: .default) { (_) -> Void in
                self.hideLoadingIndicator()
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                }
            }
            self.alert(title: "", message: "사진 촬영 권한이 없는 경우 사진을 찍을 수 없습니다. 권한 허용 후 시작하시겠습니까? ", preferredStyle: .alert, actions: [cancelAction, confirmAction], completion: nil)
            return
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
    
    private func changeBgButtonDidClicked() {
        let galleryAction = UIAlertAction(title: "내 갤러리에서 사진 선택", style: .default) { (_) in
            self.showGallery()
        }
        let defaultPhotoAction = UIAlertAction(title: "기본 이미지에서 사진 선택", style: .default) { (_) in
            self.showDefaultPhoto()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        parent?.alert(title: nil, message: nil, preferredStyle: .actionSheet, actions: [galleryAction, defaultPhotoAction, cancelAction])
    }
    
    private func scrollToPage(page: Int, animated: Bool) {
        var frame: CGRect = self.scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        self.scrollView.scrollRectToVisible(frame, animated: animated)
    }
    
    private func showGallery() {
        present(pickerController, animated: true, completion: nil)
    }
    
    private func showDefaultPhoto() {
        scrollToPage(page: 1, animated: false)
        if let selectButton = self.selectButton {
            self.selectImgButton(button: selectButton)
        } else {
            self.selectImgButton(button: templateImgButton)
        }
    }
     
    private func getDaySteps() {
        if !CMPedometer.isStepCountingAvailable() {
            Log.al("!CMPedometer.isStepCountingAvailable()")
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:ss"
        let midnight = Calendar.current.startOfDay(for: currentDay)
        var toDate = Calendar.current.date(byAdding: .hour, value: 23, to: currentDay)!
        toDate = Calendar.current.date(byAdding: .second, value: 59, to: toDate)!
        
        GlobalDefine.shared.mainHome?.pedometer.queryPedometerData(from: midnight, to: toDate) { (data, error) in
            if let error = error {
                Log.al("error = \(error)")
                return
            }
            if let getData = data {
                Log.al("getData.numberOfSteps = \(getData.numberOfSteps)")
                if self.isToday { // 오늘 날짜
                    let myClientStep = GlobalDefine.shared.currentStep
                    DispatchQueue.main.async {
                        self.cameraTemplateView.startStepUpdates(step: myClientStep)
                        self.galleryTemplateView.startStepUpdates(step: myClientStep)
                    }
                } else {
                    let stepResult = Int(truncating: getData.numberOfSteps)
                    Log.al("getData.numberOfSteps = \(stepResult)")
                    DispatchQueue.main.async {
                        self.cameraTemplateView.startStepUpdates(step: stepResult)
                        self.galleryTemplateView.startStepUpdates(step: stepResult)
                    }
                }
            }
        }
         
    }
    
    private func didTakePhoto() {
        showLoadingIndicator()
        var settings = AVCapturePhotoSettings()
        if stillImageOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        }
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func setupLivePreview() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        DispatchQueue.main.async {
            self.previewView.layer.addSublayer(self.videoPreviewLayer)
            Log.al("4444444 self.videoPreviewLayer.frame = self.previewView.bounds")
            self.videoPreviewLayer.frame = self.previewView.bounds
            if GlobalDefine.shared.isSeleteGalleryTap {
            // 포그라운드로 다시 되돌아올때는 카메라를 다시 구동해야해서 갤러리탭에 있을때는 갤러리탭으로 다시 보내줌
                self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                self.showDefaultPhoto()
            } else {
                self.showCameraTap()
            }
            
        }
    }
    
    private func switchCamera() {
        if let session = captureSession {
            let currentCameraInput: AVCaptureInput = session.inputs[0]
            session.removeInput(currentCameraInput)
            var newCamera: AVCaptureDevice
            newCamera = AVCaptureDevice.default(for: AVMediaType.video)!
            if (currentCameraInput as? AVCaptureDeviceInput)?.device.position == .back {
                UIView.transition(with: self.previewView, duration: 0.5, options: .transitionFlipFromLeft, animations: { // transitionCrossDissolve
                    newCamera = self.cameraWithPosition(.front)!
                }, completion: {_ in
                    // 전면카메라 일때는 플래시버튼 끄고 비활성화
                    self.flashOnButton.isSelected = false
                    self.flashOnButton.isEnabled = false
                })
            } else {
                UIView.transition(with: self.previewView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                    newCamera = self.cameraWithPosition(.back)!
                }, completion: {_ in
                    // 후면카메라 플래시 다시 설정
                    self.toggleTorch(on: self.isFlashOnOff)
                    self.flashOnButton.isEnabled = true
                })
            }
            do {
                try self.captureSession?.addInput(AVCaptureDeviceInput(device: newCamera))
            } catch {
                print("error: \(error.localizedDescription)")
            }
        }
    }
    
    private func toggleflash(on: Bool) {
        isFlashOnOff = !isFlashOnOff
        flashOnButton.isSelected = isFlashOnOff
        toggleTorch(on: isFlashOnOff)
    }
    
    private func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    func showCameraTap() {
        GlobalDefine.shared.isSeleteGalleryTap = false
        self.navigationItem.rightBarButtonItems = nil
        scrollToPage(page: 0, animated: false)
        
        checkAlertCameraAuthorized()
    }
    
    func flipImageLeftRight(_ image: UIImage) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: image.size.width, y: image.size.height)
        context.scaleBy(x: -image.scale, y: -image.scale)
        
        context.draw(image.cgImage!, in: CGRect(origin: CGPoint.zero, size: image.size))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // 카메라로 찍었을 때 바로 인증샷 공유 화면으로 이동
        guard let imageData = photo.fileDataRepresentation() else {
            self.hideLoadingIndicator()
            return }
        guard let image = UIImage(data: imageData) else {
            self.hideLoadingIndicator()
            return }
        var newImage: UIImage = image
        if let session = captureSession {
            let currentCameraInput: AVCaptureInput = session.inputs[0]
            if (currentCameraInput as? AVCaptureDeviceInput)?.device.position == .back {
            } else {
                // 전면카메라로 찍었을때 이미지 좌우반전
                newImage = image.flipHorizontally() ?? image
            }
        }
        self.captureImageView.image = newImage
        self.captureImageView.isHidden = false
        
        guard let captureImage = self.cameraCaptureView.asImage() else {
            self.hideLoadingIndicator()
            return}
        let controller = ShareStepsViewController(captureImage: captureImage)
        self.captureImageView.isHidden = true
        self.hideLoadingIndicator()
        GlobalFunction.pushVC(controller, animated: true)
    }
    
    private func setGestureRecognizers() {
        let panCameraSlider = UIPanGestureRecognizer(target: self, action: #selector(panCameraSlider(gesture:)))
        cameraCaptureView.addGestureRecognizer(panCameraSlider)
        
        let panGallerySlider = UIPanGestureRecognizer(target: self, action: #selector(panGallerySlider(gesture:)))
        galleryCaptureView.addGestureRecognizer(panGallerySlider)
    }
    
    @objc private func panCameraSlider(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            cameraSlider.isHidden = false
        } else if gesture.state == .ended {
            cameraSlider.isHidden = true
        }
        let yTranslation = gesture.translation(in: gesture.view).y
        let tolerance: CGFloat = 5
        let tempABS = abs(yTranslation)
        if tempABS >= tolerance {
            let tempValue1 = Float(yTranslation / tolerance)
            let tempValue2 = tempValue1 * 0.002
            let newValue = cameraSlider.value - tempValue2
            cameraSlider.setValue(newValue, animated: false)
            
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            do {
                try device.lockForConfiguration()
                device.setExposureTargetBias(newValue, completionHandler: {_ in })
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        }
    }
    
    @objc private func panGallerySlider(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            gallerySlider.isHidden = false
        } else if gesture.state == .ended {
            gallerySlider.isHidden = true
        }
        let yTranslation = gesture.translation(in: gesture.view).y
        let tolerance: CGFloat = 5
        let tempABS = abs(yTranslation)
        if  tempABS >= tolerance {
            let tempValue1 = Float(yTranslation / tolerance)
            let tempValue2 = tempValue1 * 0.00045
            let newValue = gallerySlider.value - tempValue2
            gallerySlider.setValue(newValue, animated: false)
            
            guard let originalImage = self.originalGalleryImage else {return}
            let context = CIContext()
            let filter = CIFilter(name: "CIColorControls")!
            filter.setValue(newValue, forKey: kCIInputBrightnessKey)
            let image = CIImage(image: originalImage)
            filter.setValue(image, forKey: kCIInputImageKey)
            let result = filter.outputImage!
            if let cgImage = context.createCGImage(result, from: result.extent) {
                self.galleryImageView.image = UIImage(cgImage: cgImage)
            }
        }
    }
    
    private func selectImgButton(button: UIButton) {
        self.selectButton = button
        switch button.tag {
        case 1000:
            self.templateImgButton.IBborderWidth = 3
            self.templateImgButton.IBborderColor = .blueCw
            self.templateYellowButton.IBborderWidth = 0
            self.templateYellowButton.IBborderColor = .clear
            self.templateGrayButton.IBborderWidth = 0
            self.templateGrayButton.IBborderColor = .clear
        case 2000:
            self.templateImgButton.IBborderWidth = 0
            self.templateImgButton.IBborderColor = .clear
            self.templateYellowButton.IBborderWidth = 3
            self.templateYellowButton.IBborderColor = .blueCw
            self.templateGrayButton.IBborderWidth = 0
            self.templateGrayButton.IBborderColor = .clear
        case 3000:
            self.templateImgButton.IBborderWidth = 0
            self.templateImgButton.IBborderColor = .clear
            self.templateYellowButton.IBborderWidth = 0
            self.templateYellowButton.IBborderColor = .clear
            self.templateGrayButton.IBborderWidth = 3
            self.templateGrayButton.IBborderColor = .blueCw
        default:
            self.templateImgButton.IBborderWidth = 0
            self.templateImgButton.IBborderColor = .clear
            self.templateYellowButton.IBborderWidth = 0
            self.templateYellowButton.IBborderColor = .clear
            self.templateGrayButton.IBborderWidth = 0
            self.templateGrayButton.IBborderColor = .clear
        }
    }
}

// MARK: - CustomSegmentedControlDelegate
extension ProofShotsViewController: CustomSegmentedControlDelegate {
    
    func changeToIndex(index: Int) {
        switch index {
        case 0:
            DispatchQueue.main.async {
                self.showCameraTap()
            }
        case 1:
            GlobalDefine.shared.isSeleteGalleryTap = true
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                self.showDefaultPhoto()
            }
        default:
            break
        }
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ProofShotsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 갤러리에서 사진 선택
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        showLoadingIndicator()
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            self.hideLoadingIndicator()
            dismiss(animated: true, completion: nil)
            return }
        
        DispatchQueue.main.async { 
            self.selectImgButton(button: self.galleryButton)
            self.galleryImageView.image = image
            self.originalGalleryImage = self.galleryImageView.image ?? UIImage(named: "templateImg")!
            self.gallerySlider.setValue(0, animated: false)
            self.hideLoadingIndicator()
            self.dismiss(animated: true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
