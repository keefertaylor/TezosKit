// Copyright Keefer Taylor, 2019

@testable import TezosKit
import XCTest

// swiftlint:disable line_length

class TezosNodeClientTests: XCTestCase {
  public func testPreapplyErrorFromResponse_validOperation() {
    let validPreapplyResponse = "[{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1272\",\"counter\":\"30801\",\"gas_limit\":\"10100\",\"storage_limit\":\"257\",\"amount\":\"1\",\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1272\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"level\":125,\"change\":\"1272\"}],\"operation_result\":{\"status\":\"applied\",\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"contract\",\"contract\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"change\":\"1\"}],\"consumed_gas\":\"10100\"}}}],\"signature\":\"edsigtpsh2VpWyZTZ46q9j54VfsWZLZuxL7UGEhfgCNx6SXwaWu4gMHx59bRdogbSmDCCpXeQeighgpHk5x32k3rtFu8w5EZyEr\"}]\n"
    let json = JSONArrayResponseAdapter.parse(input: validPreapplyResponse.data(using: .utf8)!)!
    XCTAssertNil(TezosNodeClient.preapplicationError(from: json))
  }

  public func testPreapplyErrorFromResponse_invalidOperation() {
    let invalidPreapplyResponse = "[{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1272\",\"counter\":\"30802\",\"gas_limit\":\"10100\",\"storage_limit\":\"257\",\"amount\":\"10000000000000\",\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1272\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"level\":125,\"change\":\"1272\"}],\"operation_result\":{\"status\":\"failed\",\"errors\":[{\"kind\":\"temporary\",\"id\":\"proto.003-PsddFKi3.contract.balance_too_low\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"balance\":\"98751713\",\"amount\":\"10000000000000\"}]}}}],\"signature\":\"edsigu16pv1NUsXuJkwWDAqvFDbhcsRAHbdxbYJcN7AShN4yDspRmsP5kgbzs2osTHGGDkyED3vjQFcbskv3BVESJ7tpchmbbop\"}]"
    let json = JSONArrayResponseAdapter.parse(input: invalidPreapplyResponse.data(using: .utf8)!)!
    let error = TezosNodeClient.preapplicationError(from: json)!
    XCTAssertEqual(error.kind, .preapplicationError)
    XCTAssert(error.underlyingError!.contains("contract.balance_too_low"))
  }
}
