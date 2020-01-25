// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

class SigningServiceTests: XCTestCase {
  func testSign() {
    let mockTransaction = "abc123"
    let expectedSignature: [UInt8] = [1, 2, 3, 4]

    let fakeSignatureProvider =
      FakeSignatureProvider(signature: expectedSignature, publicKey: FakePublicKey.testPublicKey)

    guard let signature = SigningService.sign(mockTransaction, with: fakeSignatureProvider) else {
      XCTFail()
      return
    }
    XCTAssertEqual(signature, expectedSignature)
  }
}
