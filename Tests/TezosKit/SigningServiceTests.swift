// Copyright Keefer Taylor, 2019.

import XCTest
import TezosKit

// TODO: Network client should be underlying
// TODO: Derivatives of signing result should just be raw?
// TODO: This fake stuff should really be provided by TezosCrypto.

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
