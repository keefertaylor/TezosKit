// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

class TezosNodeClientTests: XCTestCase {
  public static let timeout = 10.0

  public var nodeClient: TezosNodeClient?
  public let fakeURLSession = FakeURLSession()

  public override func setUp() {
    super.setUp()
    nodeClient = TezosNodeClient(urlSession: fakeURLSession)
  }

  public func testGetHeadHash() {
    let testHeadHash = "BM3e24i3NhYyzfZ1Rb7Lo5KZw4vV2bZWSx93TsVjxcKdaHDp6yk"
    fakeURLSession.data = testHeadHash.data(using: .utf8)

    let expectation = XCTestExpectation(description: "completion called")
    nodeClient?.getHeadHash { hash, error in
      XCTAssertEqual(hash, testHeadHash)
      XCTAssertNil(error)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: TezosNodeClientTests.timeout)
  }
}
