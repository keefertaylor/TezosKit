// Copyright Keefer Taylor, 2019

@testable import TezosKit
import XCTest

/// A fake error used in tests.
private enum TestError: Error {
  case testError
}

extension TestError: LocalizedError {
  public var errorDescription: String? {
    return "Oh no!"
  }
}

class RPCResponseHandlerTest: XCTestCase {
  /// Response handler to test.
  static let responseHandler = RPCResponseHandler()

  /// Test values.
  static let testURL = URL(string: "http://github.com/keefertaylor/TezosKit")!

  static let testErrorString = "flagrant error!"
  var testErrorStringData: Data? // Above string as raw bytes.

  static let testParsedString = "success!"
  var testParsedStringData: Data? // Above string as raw bytes.

  static let testBackTrackedString = """
[{"contents":[{"kind":"transaction","source":"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb","fee":"14464","counter":"627017","gas_limit":"139719","storage_limit":"7051","amount":"0","destination":"KT1PuoBCrK7bu9MP7LKZRhjXKZSwvgQkDrCN","parameters":{"entrypoint":"approve","value":{"prim":"Pair","args":[{"string":"KT1PxBTZFsBd1gUXhkTFpncDTjvrKbmTeHde"},{"int":"1"}]}},"metadata":{"balance_updates":[{"kind":"contract","contract":"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb","change":"-14464"},{"kind":"freezer","category":"fees","delegate":"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU","cycle":182,"change":"14464"}],"operation_result":{"status":"backtracked","storage":{"prim":"Pair","args":[{"int":"239"},{"int":"1000000"}]},"big_map_diff":[{"action":"update","big_map":"239","key_hash":"exprtkFpPpLkPNbxReKT1osWCfseKDUyyxb7URVBaX2Yw1N5Sq86hv","key":{"bytes":"0000ca1c5dd7f6665501b57c692f0726a1db46fd1d18"},"value":{"prim":"Pair","args":[[{"prim":"Elt","args":[{"bytes":"01a8969119375713736a2da93ffad0ae2f0178630100"},{"int":"1"}]}],{"int":"228"}]}}],"consumed_gas":"139619","storage_size":"6794"}}},{"kind":"transaction","source":"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb","fee":"62742","counter":"627018","gas_limit":"520845","storage_limit":"21605","amount":"0","destination":"KT1PxBTZFsBd1gUXhkTFpncDTjvrKbmTeHde","parameters":{"entrypoint":"tokenToXtz","value":{"prim":"Pair","args":[{"prim":"Pair","args":[{"prim":"Pair","args":[{"string":"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb"},{"string":"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb"}]},{"prim":"Pair","args":[{"int":"1"},{"int":"39756"}]}]},{"string":"2020-04-27T09:43:41Z"}]}},"metadata":{"balance_updates":[{"kind":"contract","contract":"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb","change":"-62742"},{"kind":"freezer","category":"fees","delegate":"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU","cycle":182,"change":"62742"}],"operation_result":{"status":"backtracked","storage":{"prim":"Pair","args":[{"int":"307"},{"prim":"Pair","args":[{"prim":"Pair","args":[{"prim":"Pair","args":[{"prim":"None"},{"prim":"None"}]},{"prim":"Pair","args":[{"int":"1580637600"},{"int":"10000000"}]}]},{"prim":"Pair","args":[{"bytes":"01a82322859105a5974ef58b465962428c567a204d00"},{"int":"1511"}]}]}]},"consumed_gas":"467921","storage_size":"15430"},"internal_operation_results":[{"kind":"transaction","source":"KT1PxBTZFsBd1gUXhkTFpncDTjvrKbmTeHde","nonce":0,"amount":"39756","destination":"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb","result":{"status":"backtracked","balance_updates":[{"kind":"contract","contract":"KT1PxBTZFsBd1gUXhkTFpncDTjvrKbmTeHde","change":"-39756"},{"kind":"contract","contract":"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb","change":"39756"}],"consumed_gas":"10207"}},{"kind":"transaction","source":"KT1PxBTZFsBd1gUXhkTFpncDTjvrKbmTeHde","nonce":1,"amount":"0","destination":"KT1PuoBCrK7bu9MP7LKZRhjXKZSwvgQkDrCN","parameters":{"entrypoint":"default","value":{"prim":"Right","args":[{"prim":"Pair","args":[{"prim":"Pair","args":[{"bytes":"0000ca1c5dd7f6665501b57c692f0726a1db46fd1d18"},{"bytes":"01a8969119375713736a2da93ffad0ae2f0178630100"}]},{"int":"1"}]}]}},"result":{"status":"failed","errors":[{"kind":"temporary","id":"proto.006-PsCARTHA.gas_exhausted.operation"}]}}]}}],"signature":"edsigtzVs2YoRGaZoDrvug9jKJz7KY7pbJymWqvG2QWxaM3SMECHHNVGEqRAAhAcBnXWBnNk7fzPVA6We1e644Qb2oZxgCR1cYy"}]{
  "contents": [{
    "kind": "transaction",
    "source": "tz1...",
    "fee": "0",
    "counter": "584586",
    "gas_limit": "800000",
    "storage_limit": "60000",
    "amount": "0",
    "destination": "KT1...",
    "parameters": {},
    "metadata": {
      "balance_updates": [],
      "operation_result": {
        "status": "backtracked",
        "storage": {},
        "consumed_gas": "67061",
        "storage_size": "1355"
      },
      "internal_operation_results": [{
        "kind": "transaction",
        "source": "KT1...",
        "nonce": 0,
        "amount": "25000000",
        "destination": "KT1",
        "result": {
          "status": "backtracked",
          "storage": { },
          "balance_updates": [ ... ],
          "consumed_gas": "37909",
          "storage_size": "1342"
        }
      },
      {
        "kind": "transaction",
        "source": "KT1...",
        "nonce": 1,
        "amount": "0",
        "destination": "KT1...",
        "parameters": {
          "entrypoint": "checkLimit",
          "value": {
            "int": "82585938"
          }
        },
        "result": {
          "status": "failed",
          "errors": [{
            "kind": "temporary",
            "id": "proto.005-PsBabyM1.michelson_v1.runtime_error",
            "contract_handle": "KT1...",
            "contract_code": [ ]
          }, {
            "kind": "temporary",
            "id": "proto.005-PsBabyM1.michelson_v1.script_rejected",
            "location": 198,
            "with": {
              "string": ""
            }
          }]
        }
      }]
    }
  }]
}
"""
  var testBacktrackedStringData: Data? // Above string as raw bytes

  static let gasExhaustedString = "[{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb\",\"fee\":\"14464\",\"counter\":\"627017\",\"gas_limit\":\"139719\",\"storage_limit\":\"7051\",\"amount\":\"0\",\"destination\":\"KT1PuoBCrK7bu9MP7LKZRhjXKZSwvgQkDrCN\",\"parameters\":{\"entrypoint\":\"approve\",\"value\":{\"prim\":\"Pair\",\"args\":[{\"string\":\"KT1PxBTZFsBd1gUXhkTFpncDTjvrKbmTeHde\"},{\"int\":\"1\"}]}},\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb\",\"change\":\"-14464\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":182,\"change\":\"14464\"}],\"operation_result\":{\"status\":\"backtracked\",\"storage\":{\"prim\":\"Pair\",\"args\":[{\"int\":\"239\"},{\"int\":\"1000000\"}]},\"big_map_diff\":[{\"action\":\"update\",\"big_map\":\"239\",\"key_hash\":\"exprtkFpPpLkPNbxReKT1osWCfseKDUyyxb7URVBaX2Yw1N5Sq86hv\",\"key\":{\"bytes\":\"0000ca1c5dd7f6665501b57c692f0726a1db46fd1d18\"},\"value\":{\"prim\":\"Pair\",\"args\":[[{\"prim\":\"Elt\",\"args\":[{\"bytes\":\"01a8969119375713736a2da93ffad0ae2f0178630100\"},{\"int\":\"1\"}]}],{\"int\":\"228\"}]}}],\"consumed_gas\":\"139619\",\"storage_size\":\"6794\"}}},{\"kind\":\"transaction\",\"source\":\"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb\",\"fee\":\"62742\",\"counter\":\"627018\",\"gas_limit\":\"520845\",\"storage_limit\":\"21605\",\"amount\":\"0\",\"destination\":\"KT1PxBTZFsBd1gUXhkTFpncDTjvrKbmTeHde\",\"parameters\":{\"entrypoint\":\"tokenToXtz\",\"value\":{\"prim\":\"Pair\",\"args\":[{\"prim\":\"Pair\",\"args\":[{\"prim\":\"Pair\",\"args\":[{\"string\":\"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb\"},{\"string\":\"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb\"}]},{\"prim\":\"Pair\",\"args\":[{\"int\":\"1\"},{\"int\":\"39756\"}]}]},{\"string\":\"2020-04-27T09:43:41Z\"}]}},\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb\",\"change\":\"-62742\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":182,\"change\":\"62742\"}],\"operation_result\":{\"status\":\"backtracked\",\"storage\":{\"prim\":\"Pair\",\"args\":[{\"int\":\"307\"},{\"prim\":\"Pair\",\"args\":[{\"prim\":\"Pair\",\"args\":[{\"prim\":\"Pair\",\"args\":[{\"prim\":\"None\"},{\"prim\":\"None\"}]},{\"prim\":\"Pair\",\"args\":[{\"int\":\"1580637600\"},{\"int\":\"10000000\"}]}]},{\"prim\":\"Pair\",\"args\":[{\"bytes\":\"01a82322859105a5974ef58b465962428c567a204d00\"},{\"int\":\"1511\"}]}]}]},\"consumed_gas\":\"467921\",\"storage_size\":\"15430\"},\"internal_operation_results\":[{\"kind\":\"transaction\",\"source\":\"KT1PxBTZFsBd1gUXhkTFpncDTjvrKbmTeHde\",\"nonce\":0,\"amount\":\"39756\",\"destination\":\"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb\",\"result\":{\"status\":\"backtracked\",\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"KT1PxBTZFsBd1gUXhkTFpncDTjvrKbmTeHde\",\"change\":\"-39756\"},{\"kind\":\"contract\",\"contract\":\"tz1e4hAp7xpjekmXnYe4677ELGA3UxR79EFb\",\"change\":\"39756\"}],\"consumed_gas\":\"10207\"}},{\"kind\":\"transaction\",\"source\":\"KT1PxBTZFsBd1gUXhkTFpncDTjvrKbmTeHde\",\"nonce\":1,\"amount\":\"0\",\"destination\":\"KT1PuoBCrK7bu9MP7LKZRhjXKZSwvgQkDrCN\",\"parameters\":{\"entrypoint\":\"default\",\"value\":{\"prim\":\"Right\",\"args\":[{\"prim\":\"Pair\",\"args\":[{\"prim\":\"Pair\",\"args\":[{\"bytes\":\"0000ca1c5dd7f6665501b57c692f0726a1db46fd1d18\"},{\"bytes\":\"01a8969119375713736a2da93ffad0ae2f0178630100\"}]},{\"int\":\"1\"}]}]}},\"result\":{\"status\":\"failed\",\"errors\":[{\"kind\":\"temporary\",\"id\":\"proto.006-PsCARTHA.gas_exhausted.operation\"}]}}]}}],\"signature\":\"edsigtzVs2YoRGaZoDrvug9jKJz7KY7pbJymWqvG2QWxaM3SMECHHNVGEqRAAhAcBnXWBnNk7fzPVA6We1e644Qb2oZxgCR1cYy\"}]"

  public override func setUp() {
    super.setUp()

    testErrorStringData = RPCResponseHandlerTest.testErrorString.data(using: .utf8)!
    testParsedStringData = RPCResponseHandlerTest.testParsedString.data(using: .utf8)!
    testBacktrackedStringData = RPCResponseHandlerTest.testBackTrackedString.data(using: .utf8)!
  }

  public func testHandleResponseWithHTTP400() {
    let response = httpResponse(with: 400)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testErrorStringData,
      error: TestError.testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      XCTAssertEqual(tezosKitError, .unexpectedRequestFormat(description: RPCResponseHandlerTest.testErrorString))
    case .success:
      XCTFail()
    }
  }

  public func testHandleResponseWithHTTP500() {
    let response = httpResponse(with: 500)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testErrorStringData,
      error: TestError.testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      XCTAssertEqual(tezosKitError, .unexpectedResponse(description: RPCResponseHandlerTest.testErrorString))
    case .success:
      XCTFail()
    }
  }

  public func testHandleResponseWithHTTPInvalid() {
    let response = httpResponse(with: 9_000)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testErrorStringData,
      error: TestError.testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      XCTAssertEqual(tezosKitError, .unknown(description: RPCResponseHandlerTest.testErrorString))
    case .success:
      XCTFail()
    }
  }

  public func testHandleResponseWithHTTP200AndError() {
    let response = httpResponse(with: 200)
    let testError = TestError.testError
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testParsedStringData,
      error: testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      switch tezosKitError {
      case .rpcError(let description):
        XCTAssertEqual(description, testError.localizedDescription)
      default:
        XCTFail("Wrong error type reported.")
      }
    case .success:
      XCTFail()
    }
  }
  public func testHandleResponseWithHTTP200AndBacktrackedOperation() {
    let response = httpResponse(with: 200)
    let testError = TestError.testError
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testBacktrackedStringData,
      error: testError,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      guard case .operationError = tezosKitError else {
        XCTFail("Wrong error type reported")
        return
      }

    case .success:
      XCTFail()
    }
  }

  public func testHandleResponseWithHTTP200AndNilErrorAndValidData() {
    let response = httpResponse(with: 200)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testParsedStringData,
      error: nil,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure:
      XCTFail()
    case .success(let data):
      XCTAssertEqual(data, RPCResponseHandlerTest.testParsedString)
    }
  }

  public func testHandleResponseWithHTTP200AndNilErrorAndNoData() {
    let response = httpResponse(with: 200)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: nil,
      error: nil,
      responseAdapterClass: StringResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      XCTAssertEqual(tezosKitError, .unexpectedResponse(description: "No data in response"))
    case .success:
      XCTFail()
    }
  }

  public func testHandleResponseWithHTTP200AndNilErrorAndBadData() {
    let response = httpResponse(with: 200)
    let result = RPCResponseHandlerTest.responseHandler.handleResponse(
      response: response,
      data: testParsedStringData,
      error: nil,
      responseAdapterClass: PeriodKindResponseAdapter.self
    )

    switch result {
    case .failure(let tezosKitError):
      XCTAssertEqual(tezosKitError, .unexpectedResponse(description: "Could not parse response"))
    case .success:
      XCTFail()
    }
  }

// MARK: - Helpers

  private func httpResponse(with code: Int) -> HTTPURLResponse {
    return HTTPURLResponse(url: RPCResponseHandlerTest.testURL, statusCode: code, httpVersion: nil, headerFields: nil)!
  }
}
