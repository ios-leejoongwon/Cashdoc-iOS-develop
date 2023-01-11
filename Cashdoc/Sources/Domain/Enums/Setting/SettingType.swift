//
//  SettingType.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct SettingTypeCell {
    let title: String
}

enum SettingType: String, CaseIterable {
    // mydata 관련히든
    // case myProperty = "내 자산"
    case manager = "캐시닥 관리"
    case serviceCenter = "고객센터"
    #if DEBUG || INHOUSE
    case debugMode = "테스트 모드"
    #endif
    
    // MARK: - Properties
    
    var cells: [SettingTypeCell] {
        var cells = [SettingTypeCell]()
        switch self {
        // mydata 관련히든
//        case .myProperty:
//            cells.append(.init(title: "연동 상태 관리"))
        case .manager:
            cells.append(.init(title: "현재 앱 버전"))
            cells.append(.init(title: "앱 잠금 설정"))
            cells.append(.init(title: "알림 설정"))
            if #available(iOS 14, *) {
                cells.append(.init(title: "맞춤 정보 제공"))
            }
        case .serviceCenter:
            cells.append(.init(title: "공지사항"))
            cells.append(.init(title: "불편신고"))
            cells.append(.init(title: "이용약관"))
            cells.append(.init(title: "개인정보처리방침"))
        #if DEBUG || INHOUSE
        case .debugMode:
            cells.append(.init(title: "테스트 모드"))
        #endif
        }
        return cells
    }
    
    var numberOfItems: Int {
        return cells.count
    }
}
