// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

class SigningServiceTests: XCTestCase {
  func testSign() {
    let mockTransaction = "abc123"
    let expectedSignature: [UInt8] = [1, 2, 3, 4]

    let fakeSigner = FakeSigner(signature: expectedSignature)

    guard let signingResult = SigningService.sign(mockTransaction, with: fakeSigner) else {
      XCTFail()
      return
    }
    XCTAssertEqual(signingResult.signature, expectedSignature)
  }
}
