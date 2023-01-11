import XCTest

@testable import Cashdoc

class ReplaceRootViewControllerTests: XCTestCase {
    
    var keyWindow: UIWindow!
    var rootViewController: UIViewController!
    
    override func setUp() {
        guard let window = UIApplication.shared.keyWindow else {
            fatalError("Unable to find window")
        }
        rootViewController = UIViewController()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.keyWindow = window
        
        RunLoop.current.run(until: Date())
    }
    
    override func tearDown() {
        
        super.tearDown()
    }

    func testSnapshot() {
        // Given
        let snapshot = keyWindow.snapshot
        
        // Then
        XCTAssertNotNil(snapshot)
    }
    
    func testReplaceRootViewController() {
        // Given
        let expectation = self.expectation(description: "testReplaceRootViewController")
        let controller = UIViewController()
        
        // When
        rootViewController.present(controller, animated: true) {
            self.keyWindow.replaceRootViewController(with: nil, animated: true) {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: timeout)
        
        // Then
        XCTAssertNil(keyWindow.rootViewController)
    }
    
}
