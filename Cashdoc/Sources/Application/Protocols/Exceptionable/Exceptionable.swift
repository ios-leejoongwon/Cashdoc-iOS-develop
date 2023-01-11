//
//  Exceptionable.swift
//  Cashdoc
//
//  Created by DongHeeKang on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa

class Exceptionable<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

protocol ExceptionableCompatible: AnyObject {
    associatedtype ExceptionableType
    var exceptionable: ExceptionableType { get }
}

extension ExceptionableCompatible {
    var exceptionable: Exceptionable<Self> {
        return Exceptionable(self)
    }
}
