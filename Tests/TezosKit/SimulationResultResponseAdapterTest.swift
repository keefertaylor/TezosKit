// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

final class SimulationResultResponseAdapterTest: XCTestCase {
  /// A transaction which only consumes gas.
  func testSuccessfulTransaction() {
    let input = "{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1\",\"counter\":\"31127\",\"gas_limit\":\"100000\",\"storage_limit\":\"10000\",\"amount\":\"1000000\",\"destination\":\"KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":284,\"change\":\"1\"}],\"operation_result\":{\"status\":\"applied\",\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1000000\"},{\"kind\":\"contract\",\"contract\":\"KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka\",\"change\":\"1000000\"}],\"consumed_gas\":\"10200\"}}}]}"
    guard
      let inputData = input.data(using: .utf8),
      let simulationResult = SimulationResultResponseAdapter.parse(input: inputData)
    else {
      XCTFail();
      return
    }

    guard case .success(let consumedGas, let consumedStorage) = simulationResult else {
      XCTFail()
      return
    }

    XCTAssertEqual(consumedGas, 10200)
    XCTAssertEqual(consumedStorage, 0)
  }

  /// A transaction that consumes gas and storage.
  func testSuccessfulContractInvocation() {
    let input = "{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1\",\"counter\":\"31127\",\"gas_limit\":\"100000\",\"storage_limit\":\"10000\",\"amount\":\"0\",\"destination\":\"KT1XsHrcWTmRFGyPgtzEHb4fb9qDAj5oQxwB\",\"parameters\":{\"string\":\"TezosKit\"},\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":284,\"change\":\"1\"}],\"operation_result\":{\"status\":\"applied\",\"storage\":{\"string\":\"TezosKit\"},\"consumed_gas\":\"11780\",\"storage_size\":\"49\"}}}]}"
    guard
      let inputData = input.data(using: .utf8),
      let simulationResult = SimulationResultResponseAdapter.parse(input: inputData)
      else {
        XCTFail();
        return
    }

    guard case .success(let consumedGas, let consumedStorage) = simulationResult else {
      XCTFail()
      return
    }

    XCTAssertEqual(consumedGas, 11780)
    XCTAssertEqual(consumedStorage, 49)
  }

  /// Failed transaction - attempted to send too many Tez.
  public func testFailureOperationParameters() {
    let input = "{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1\",\"counter\":\"31127\",\"gas_limit\":\"100000\",\"storage_limit\":\"10000\",\"amount\":\"10000000000000000\",\"destination\":\"KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":284,\"change\":\"1\"}],\"operation_result\":{\"status\":\"failed\",\"errors\":[{\"kind\":\"temporary\",\"id\":\"proto.004-Pt24m4xi.contract.balance_too_low\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"balance\":\"400570851\",\"amount\":\"10000000000000000\"}]}}}]}"
    guard
      let inputData = input.data(using: .utf8),
      let simulationResult = SimulationResultResponseAdapter.parse(input: inputData)
      else {
        XCTFail();
        return
    }

    guard case .failure = simulationResult else {
      XCTFail()
      return
    }
  }

  /// Failed transaction - too low of gas limit
  public func testFailureExhaustedGas() {
    let input = "{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1\",\"counter\":\"31127\",\"gas_limit\":\"0\",\"storage_limit\":\"10000\",\"amount\":\"10000000000000000\",\"destination\":\"KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":284,\"change\":\"1\"}],\"operation_result\":{\"status\":\"failed\",\"errors\":[{\"kind\":\"temporary\",\"id\":\"proto.004-Pt24m4xi.gas_exhausted.operation\"}]}}}]}"
    guard
      let inputData = input.data(using: .utf8),
      let simulationResult = SimulationResultResponseAdapter.parse(input: inputData)
      else {
        XCTFail();
        return
    }

    guard case .failure = simulationResult else {
      XCTFail()
      return
    }
  }
}

