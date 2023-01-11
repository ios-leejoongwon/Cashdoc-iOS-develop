import XCTest
@testable import Cashdoc
@testable import SmartAIB
@testable import RxSwift
@testable import RxCocoa

final class ScrapingTests: XCTestCase {
    
    func test_compareAfterDateWithToday() {
        // Given
        let exceptation = XCTestExpectation()
        
//        let input = "20191127"
        let input = "20200123240000"
        
        var result: Bool?
        
        // When
        let date = input.prefix(12)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        formatter.timeZone = TimeZone(secondsFromGMT: 9)
        switch formatter.date(from: String(date))?.compare(Date()).rawValue {
        case -1 :
            result = false
            exceptation.fulfill()
        default:
            result = true
            exceptation.fulfill()
        }
        
        // Then
        XCTAssertEqual(result, true)
        
    }
    var disposeBag = DisposeBag()
    func test_getUserCheck() {
        
        let test = BehaviorSubject<Int>(value: 0)
        
        test
            .map({ (count) in
                
            })
//            .flatMap({ (_) -> ObservableConvertibleType in
//
//            })
//            .flatMapFirst({ (_) -> ObservableConvertibleType in
//
//            })
//            .flatMapLatest({ (_) -> ObservableConvertibleType in
//
//            })
//            .concatMap({ (_) -> ObservableConvertibleType in
//
//            })
//            .composeMap({ (_) -> R in
//
//            })
            .subscribe(onNext: { (test) in
                print("osh sub : \(test)")
            }, onError: { (error) in
                print("osh error : \(error)")
            }, onCompleted: {
                print("osh com")
            }, onDisposed: {
                print("osh dispo")
            }).disposed(by: disposeBag)
        
        test.asDriver(onErrorJustReturn: 100)
            .drive(onNext: { (int) in
                print("wef \(int)")
            }, onCompleted: {
                print("wefd")
            }) {
                print("wedf")
        }.disposed(by: disposeBag)
        
        test.onNext(1)
        test.onNext(2)
        test.onNext(3)
        test.onError(SapError())
        test.onNext(5)
        test.onNext(6)
    }
    
}

struct SapError: Error {
    //let error: Error
}

