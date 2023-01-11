//
//  TutorialDialog.swift
//  Cashdoc
//
//  Created by Oh Sangho on 23/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum TutorialDialog: Int, CaseIterable {
    case question0 = 0
    case question1
    case answer0
    case question2
    case giftItem
    case question3
    case question4
    case answer1
    case question5
    case question6
    case answer2
    case question7
    case brandImg
    case question8
    
    var value: [String] {
        switch self {
        case .question0:
            return ["안녕하세요. ", "님!\n돈 버는 자동가계부 캐시닥입니다."]
        case .question1:
            return ["오늘 캐시닥을 설치하신\n", "님을 위해 제가 특별한 \n선물을 준비했어요."]
        case .answer0:
            return ["뭔데?", "궁금한데?"]
        case .question2:
            return ["그 선물은 바로! 두구두구두구"]
        case .giftItem:
            return  ["imgHotStarbucks", "imgIceStarbucks"]
        case .question3:
            return ["저와 함께 일주일만 캐시를 모으시면 \n어느새 커피 한 잔을 손에 들고 계실거예요."]
        case .question4:
            return ["캐시 모으는 방법이 궁금하세요?"]
        case .answer1:
            return ["어떻게 모아?", "어서 알려줘!"]
        case .question5:
            return ["잘하셨어요! 이렇게 하루 100캐시까지 \n적립하실 수 있어요."]
        case .question6:
            return ["매일 자정이 지나면 쌓여 있는 캐시가 \n사라지니 잊지 말고 적립하세요."]
        case .answer2:
            return ["오케이", "알았어"]
        case .question7:
            return ["이렇게 적립하신 캐시는 커피 말고도 \n전국 수만개의 제휴점에서 현금처럼 \n사용하실 수 있어요!"]
        case .brandImg:
            return ["imgTutorialBrand"]
        case .question8:
            return ["자~ 그럼 편하게 돈 관리하면서 \n돈 버는 캐시닥을 같이 시작해볼까요?"]
        }
    }
    
    var isStart: Bool {
        switch self {
        case .question0, .question2, .question5, .question7:
            return true
        default:
            return false
        }
    }
    
    var isStop: Bool {
        switch self {
        case .question1, .question4, .question6:
            return true
        default:
            return false
        }
    }
    
    var isNeedName: Bool {
        switch self {
        case .question0, .question1:
            return true
        default:
            return false
        }
    }
    
    var isAnswer: Bool {
        switch self {
        case .answer0, .answer1, .answer2:
            return true
        default:
            return false
        }
    }
    
    var isImage: Bool {
        switch self {
        case .giftItem, .brandImg:
            return true
        default:
            return false
        }
    }
    
    var isTutorial: Bool {
        switch self {
        case .question5:
            return true
        default:
            return false
        }
    }
}

enum TutorialGiftType {
    case Hot
    case Ice
    
    var months: [Int] {
        switch self {
        case .Hot:
            return [9, 10, 11, 12, 1, 2, 3, 4]
        case .Ice:
            return [5, 6, 7, 8]
        }
    }
}
