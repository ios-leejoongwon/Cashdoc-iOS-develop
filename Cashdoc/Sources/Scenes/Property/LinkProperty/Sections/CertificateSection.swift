//
//  CertificateSection.swift
//  Cashdoc
//
//  Created by Oh Sangho on 08/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxDataSources

enum CertificateSection {
    case section(items: [CertificateSectionItem])
}

extension CertificateSection: SectionModelType {
    typealias Item = CertificateSectionItem
    
    var title: String {
        return ""
    }
    
    var items: [Item] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: CertificateSection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}

enum CertificateSectionItem {
    case cert(certInfo: FindedCertInfo)
}
