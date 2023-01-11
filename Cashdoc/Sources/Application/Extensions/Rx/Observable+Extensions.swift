//
//  Observable+Extensions.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

extension ObservableType where Element == Bool {
    
    func not() -> Observable<Bool> {
        return map(!)
    }
    
}

extension SharedSequenceConvertibleType {
    
    func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
        return map { _ in }
    }
    
}

extension ObservableType {
    
//    func catchErrorJustNever() -> Observable<Element> {
//        return catchError(`catch`(<#T##handler: (Error) throws -> Observable<Element>##(Error) throws -> Observable<Element>#>))
//    }
//    
//    func catchErrorJustComplete() -> Observable<Element> {
//        return catchErrorJustComplete()
//    }
    
    func asDriverOnErrorJustNever() -> Driver<Element> {
        return asDriver(onErrorDriveWith: .never())
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver(onErrorDriveWith: .empty())
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
}

extension PrimitiveSequence {
    
    func asDriverOnErrorJustNever() -> Driver<Element> {
        return asDriver(onErrorDriveWith: .never())
    }
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver(onErrorDriveWith: .empty())
    }
    
}
