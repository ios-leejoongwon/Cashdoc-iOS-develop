import XCTest
@testable import Cashdoc

import Moya
import RxSwift

final class ImportCertTests: XCTestCase {
    
    // MARK: - Properties
    
    // MARK: - Tests
    
    func test_CertificatePathCheck() {
        
        // Given
        
        let rootPath: String = ""
        let exceptation = XCTestExpectation()
        
        // When
        
        guard let subRange = rootPath.uppercased().range(of: "/CN") else {
            print("osh fail range")
            return
        }
        let startIdx = rootPath.index(after: subRange.lowerBound)
        let cn = rootPath[startIdx..<rootPath.endIndex]
        
        print("osh cn : \(String(cn))")
        exceptation.fulfill()
        
        // Then
        XCTAssertNotNil(cn)
    }
    
}
