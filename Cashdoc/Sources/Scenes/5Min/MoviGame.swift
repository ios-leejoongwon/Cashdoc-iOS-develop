//
//  MoviGame.swift
//  Cashwalk
//
//  Created by DongHeeKang on 12/02/2019.
//  Copyright © 2019 Cashwalk, Inc. All rights reserved.
//

enum MoviGame: Int {
    case 상하이타운 = 1
    case 펭귄대쉬_1 = 2
    case 네오2048_1 = 3
    case 상하이쉐프 = 4
    case 스페이스버블 = 5
    case 좀비건 = 7
    case 코스믹팝 = 8
    case 네코팡 = 9
    case 괴도러쉬_1 = 21
    case 페인팅컷 = 24
    case 펭귄구조대 = 25
    case 컬러팝_1 = 31
    
    case 펭귄대쉬_2 = 501
    case 네오2048_2 = 502
    case 좀비건_2 = 503
    case 괴도러쉬_2 = 504
    case 컬러팝_2 = 505
    
    case 행운로또 = 601
    case 돼지경주 = 602
    case 도전삼세판 = 603
    case 행운주사위 = 604
    case 윷놀이 = 605
    
    var name: String {
        switch self {
        case .상하이타운:
            return "상하이타운"
        case .펭귄대쉬_1:
            return "펭귄대쉬"
        case .네오2048_1:
            return "네오2048"
        case .상하이쉐프:
            return "상하이쉐프"
        case .스페이스버블:
            return "스페이스버블"
        case .좀비건:
            return "좀비건"
        case .코스믹팝:
            return "코스믹팝"
        case .네코팡:
            return "네코팡"
        case .괴도러쉬_1:
            return "괴도러쉬"
        case .페인팅컷:
            return "페인팅컷"
        case .펭귄구조대:
            return "펭귄구조대"
        case .컬러팝_1:
            return "컬러팝"
            
        case .펭귄대쉬_2:
            return "펭귄대쉬"
        case .네오2048_2:
            return "네오2048"
        case .좀비건_2:
            return "좀비건"
        case .괴도러쉬_2:
            return "괴도러쉬"
        case .컬러팝_2:
            return "컬러팝"
            
        case .행운로또:
            return "행운로또"
        case .돼지경주:
            return "돼지경주"
        case .도전삼세판:
            return "도전삼세판"
        case .행운주사위:
            return "행운주사위"
        case .윷놀이:
            return "윷놀이"
        }
    }
}
