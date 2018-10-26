import XCTest
import TezosKit

class ForgeOperationRPCTest: XCTestCase {
  public func testForgeOperationRPC() {
    let chainID = "abc123"
    let headHash = "xyz"
    let payload = "payload"
    let rpc = ForgeOperationRPC(chainID: chainID, headHash: headHash, payload: payload) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "/chains/" + chainID + "/blocks/" + headHash + "/helpers/forge/operations")
    XCTAssertEqual(rpc.payload, payload)
    XCTAssertTrue(rpc.isPOSTRequest)
  }
}
