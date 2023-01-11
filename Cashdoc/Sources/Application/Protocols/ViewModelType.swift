//
//  ViewModelType.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
