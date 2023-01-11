//
//  PointUseCase.swift
//  Cashdoc
//
//  Created by Taejune Jung on 05/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class PointUseCase {
    
    private let provider = CashdocProvider<PointService>()
    
    func getCurrentPoint(getError: PublishRelay<Error>) -> Driver<CurrentPoint> {
        return provider
            .request(CurrentPoint.self, token: .getPoint)
            .do(onError: { error in
                getError.accept(error)
            })
            .asDriverOnErrorJustNever()
    }
}
