// Copyright Keefer Taylor, 2018

@testable import TezosKit
import XCTest

class TezosKitErrorCodesTest: XCTestCase {
  public func testLocalizedDescription() {
    let errorKind: TezosKitError.ErrorKind = .unexpectedResponse
    let expectedLocalizedDescription = "TezosKitError \(errorKind.rawValue)"

    let error = TezosKitError(kind: errorKind, underlyingError: nil)

    let localizedDescription = error.localizedDescription

    XCTAssertEqual(localizedDescription, expectedLocalizedDescription)
  }

  public func testLocalizedDescriptionWithUnderlyingError() {
    let errorKind: TezosKitError.ErrorKind = .unexpectedResponse
    let errorString = "A string describing an error"
    let expectedLocalizedDescription = "\(errorString) (TezosKitError \(errorKind.rawValue))"

    let error = TezosKitError(kind: errorKind, underlyingError: errorString)

    let localizedDescription = error.localizedDescription

    XCTAssertEqual(localizedDescription, expectedLocalizedDescription)
  }
}
