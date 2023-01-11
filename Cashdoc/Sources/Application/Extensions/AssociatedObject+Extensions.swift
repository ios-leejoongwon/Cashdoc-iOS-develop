//
//  AssociatedObject+Extensions.swift
//  Cashdoc
//
//  Created by DongHeeKang on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import ObjectiveC

func objc_getAssociatedObject<T>(_ object: Any, _ key: UnsafeRawPointer, defaultValue: T) -> T {
    guard let value = ObjectiveC.objc_getAssociatedObject(object, key) as? T else {return defaultValue}
    return value
}
