// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class TezosClientErrorCodesTest: XCTestCase {
  public func testLocalizedDescription() {
    let errorKind: TezosClientError.ErrorKind = .unexpectedResponse
    let expectedLocalizedDescription = "TezosClientError \(errorKind.rawValue)"

    let error = TezosClientError(kind: errorKind, underlyingError: nil)

    let localizedDescription = error.localizedDescription

    XCTAssertEqual(localizedDescription, expectedLocalizedDescription)
  }

  public func testLocalizedDescriptionWithUnderlyingError() {
    let errorKind: TezosClientError.ErrorKind = .unexpectedResponse
    let errorString = "A string describing an error"
    let expectedLocalizedDescription = "\(errorString) (TezosClientError \(errorKind.rawValue))"

    let error = TezosClientError(kind: errorKind, underlyingError: errorString)

    let localizedDescription = error.localizedDescription

    XCTAssertEqual(localizedDescription, expectedLocalizedDescription)
  }
}
