//
//  CommunityType.swift
//  Cashdoc
//
//  Created by 이아림 on 2021/10/08.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Foundation

enum CommunityType: String, CaseIterable {
    case a = "고혈압/당뇨"
    case b = "관절염/골다공증"
    case c = "두통/목디스크"
    case d = "비염,축농증,천식"
    case e = "비만/다이어트"
    case f = "우울증/공항장애"
    case g = "코로나19/백신"
    case h = "코골이/수면무호홉"
    case i = "탈모"
    case j = "피부/고민/시술/미용"
    case k = "육아상담"
    case l = "마음이 아파요"
    case m = "다른 아픔이 있어요"
    case n = "발기부전/전립선염"
    case o = "생리불순/폐경/여성"
    case aa = "캐시워크 돈버는 퀴즈"
    
    var urlString: String {
        switch self {
        case .aa: return "https://cafe.daum.net/avocatalk/XtTQ"
        case .a: return "https://cafe.daum.net/avocatalk/Xt7E"
        case .b: return "https://cafe.daum.net/avocatalk/Xt72"
        case .c: return "https://cafe.daum.net/avocatalk/Xtre"
        case .d: return "https://cafe.daum.net/avocatalk/Xtv3"
        case .e: return "https://cafe.daum.net/avocatalk/Xt7O"
        case .f: return "https://cafe.daum.net/avocatalk/XvTy"
        case .g: return "https://cafe.daum.net/avocatalk/XtfD"
        case .h: return "https://cafe.daum.net/avocatalk/Xt7D"
        case .i: return "https://cafe.daum.net/avocatalk/Xt7K"
        case .j: return "https://cafe.daum.net/avocatalk/Xtoa"
        case .k: return "https://cafe.daum.net/avocatalk/XtfC"
        case .l: return "https://cafe.daum.net/avocatalk/Xt7N"
        case .m: return "https://cafe.daum.net/avocatalk/Xt7J"
        case .n: return "https://cafe.daum.net/avocatalk/Xt7L"
        case .o: return "https://cafe.daum.net/avocatalk/Xt7M"
        }
    }

}
