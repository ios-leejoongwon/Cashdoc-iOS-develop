import XCTest
@testable import Cashdoc

import Moya
import RxSwift

final class PropertyServiceTests: XCTestCase {

    private struct Result: Decodable {
        let result: String?
    }
    
    // MARK: - Properties
    
    let provider = CashdocProvider<PropertyService>()
    let disposeBag = DisposeBag()
    
    // MARK: - Tests
}
