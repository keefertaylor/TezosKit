// Copyright Keefer Taylor, 2019

import XCTest

@testable import TezosKit

final class ConseilClientTests: XCTestCase {
  let conseilClient = ConseilClient(networkClient: FakeNetworkClient.conseilClient)

  func testSent() {
    let expectation = XCTestExpectation(description: "completion called")
    conseilClient.transactionsSent(from: Wallet.testWallet.address) { result in
      switch result {
      case .success(let results):
        XCTAssert(results.count > 1)
        expectation.fulfill()
      case .failure:
        XCTFail()
      }
    }
    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testCombineResults_bothNil() {
    let a: Result<[Transaction], TezosKitError>? = nil
    let b: Result<[Transaction], TezosKitError>? = nil
    XCTAssertNil(ConseilClient.combine(a, b))
  }

  func testCombineResults_aNil() {
    let a: Result<[Transaction], TezosKitError>? = nil
    let b: Result<[Transaction], TezosKitError>? = .failure(TezosKitError(kind: .unknown))
    XCTAssertNil(ConseilClient.combine(a, b))
  }

  func testCombineResults_bNil() {
    let a: Result<[Transaction], TezosKitError>? = .failure(TezosKitError(kind: .unknown))
    let b: Result<[Transaction], TezosKitError>? = nil
    XCTAssertNil(ConseilClient.combine(a, b))
  }

  func testCombineResults_bothNoNil() {
    let a: Result<[Transaction], TezosKitError>? = .failure(TezosKitError(kind: .unknown))
    let b: Result<[Transaction], TezosKitError>? = .failure(TezosKitError(kind: .unknown))
    XCTAssertNotNil(ConseilClient.combine(a, b))
  }

  func testCombineResults_bothFailure() {
    let errorA = TezosKitError(kind: .unexpectedResponse)
    let a: Result<[Transaction], TezosKitError> = .failure(errorA)

    let errorB = TezosKitError(kind: .invalidURL)
    let b: Result<[Transaction], TezosKitError> = .failure(errorB)

    guard let result = ConseilClient.combine(a, b) else {
      XCTFail()
      return
    }
    switch result {
    case .failure(let error):
      XCTAssertEqual(errorA, error)
    case .success:
      XCTFail()
    }
  }

  func testCombineResults_aFailure() {
    let errorA = TezosKitError(kind: .unexpectedResponse)
    let a: Result<[Transaction], TezosKitError> = .failure(errorA)

    let b: Result<[Transaction], TezosKitError> = .success([.testTransaction])

    guard let result = ConseilClient.combine(a, b) else {
      XCTFail()
      return
    }
    switch result {
    case .failure(let error):
      XCTAssertEqual(errorA, error)
    case .success:
      XCTFail()
    }
  }

  func testCombineResults_bFailure() {
    let a: Result<[Transaction], TezosKitError> = .success([.testTransaction])

    let errorB = TezosKitError(kind: .invalidURL)
    let b: Result<[Transaction], TezosKitError> = .failure(errorB)

    guard let result = ConseilClient.combine(a, b) else {
      XCTFail()
      return
    }
    switch result {
    case .failure(let error):
      XCTAssertEqual(error, errorB)
    case .success:
      XCTFail()
    }
  }

  func testCombineResults_bothSuccess() {
    let a: Result<[Transaction], TezosKitError> = .success([.testTransaction])
    let b: Result<[Transaction], TezosKitError> = .success([.testTransaction])

    guard let result = ConseilClient.combine(a, b) else {
      XCTFail()
      return
    }
    switch result {
    case .failure:
      XCTFail()
    case .success(let combined):
      XCTAssertEqual(combined.count, 2)
    }
  }
}
