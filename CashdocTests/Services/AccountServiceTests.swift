import XCTest
@testable import Cashdoc

import Moya
import RxSwift

final class AccountServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    let provider = CashdocProvider<AccountService>()
    let disposeBag = DisposeBag()
    
    // MARK: - Tests
    
    func testPostAccount() {
        // Given
        let exceptation = self.expectation(description: "testPostAccount")
        let type: LoginType = .kakao
        let id = "1112465915"
        let accessToken = "-hHFeLexPP55Gfd3BinbzDF5typbnW8D60_aaQorDNIAAAFrhxHmBw"
        let username = "QA"
        let profileURL = "https://k.kakaocdn.net/dn/tgH1S/btqwgBKANjN/SfL8HlHFcTWLqocJmOx580/profile_640x640s.jpg"
        let email = "qa@cashwalk.io"
        var result: PostAccountResultModel?
        
        // When
        provider.request(PostAccountModel.self,
                         token: .postAccount(type: type,
                                             id: id,
                                             accessToken: accessToken,
                                             idToken: id,
                                             username: username,
                                             profileURL: profileURL,
                                             email: email))
            .subscribe(onSuccess: { (model) in
                result = model.result
                exceptation.fulfill()
            }, onError: { (_) in
                exceptation.fulfill()
            })
            .disposed(by: disposeBag)
        wait(for: [exceptation], timeout: timeout)
        
        // Then
        XCTAssertNotNil(result)
    }
    
}
