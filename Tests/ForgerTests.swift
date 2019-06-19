// Copyright Keefer Taylor 2019.

import TezosKit
import XCTest

class ForgerTests: XCTestCase {
  func testBool() {
    XCTAssertEqual(Forger.forge(bool: true), "ff")
    XCTAssertEqual(Forger.forge(bool: false), "00")
  }

  func testAddress() {
    XCTAssertEqual(
      Forger.forge(address: "tz1Y68Da76MHixYhJhyU36bVh7a8C9UmtvrR"),
      "00008890efbd6ca6bbd7771c116111a2eec4169e0ed8"
    )
    XCTAssertEqual(
      Forger.forge(address: "tz2LBtbMMvvguWQupgEmtfjtXy77cHgdr5TE"),
      "0001823dd85cdf26e43689568436e43c20cc7c89dcb4"
    )
    XCTAssertEqual(
      Forger.forge(address: "tz3e75hU4EhDU3ukyJueh5v6UvEHzGwkg3yC"),
      "0002c2fe98642abd0b7dd4bc0fc42e0a5f7c87ba56fc"
    )
    XCTAssertEqual(
      Forger.forge(address: "KT1NrjjM791v7cyo6VGy7rrzB3Dg3p1mQki3"),
      "019c96e27f418b5db7c301147b3e941b41bd224fe400"
    )

    XCTAssertNil(Forger.forge(address: "tezosKit"))
  }

  func testUnsignedInt() {
    XCTAssertEqual(Forger.forge(unsignedInt: 7), "07")
    XCTAssertEqual(Forger.forge(unsignedInt: 32), "20")
    XCTAssertEqual(Forger.forge(unsignedInt: 4096), "8020")
    XCTAssertEqual(Forger.forge(unsignedInt: 0), "00")
  }

  func testSignedInt() {
    XCTAssertEqual(Forger.forge(signedInt: 0), "00")
    XCTAssertEqual(Forger.forge(signedInt: -64), "c001")
    XCTAssertEqual(Forger.forge(signedInt: -120053), "f5d30e")
    XCTAssertEqual(Forger.forge(signedInt: 30268635200), "80e1b5c2e101")
    XCTAssertEqual(Forger.forge(signedInt: 610913435200), "80f9b9d4c723")
  }

  // Expected: 11 110101 11010011 00001110
  // Actual  : 11 101010 10111101 00000101

  func testBranch() {
    XCTAssertEqual(
      Forger.forge(branch: "BLNB68pLiAgXiJHXNUK7CDKRnCx1TqzaNGsRXsASg38wNueb8bx"),
      "560a037fdd573fcb59a49b5835658fab813b57b3a25e96710ec97aad0614c34f"
    )

    XCTAssertNil(Forger.forge(branch: "tezosKit"))
  }

  /// TODO: Test public keys.
}
