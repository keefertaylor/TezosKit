// Copyright Keefer Taylor, 2019.

import TezosKit
import XCTest

// swiftlint:disable line_length

final class SimulationResultResponseAdapterTest: XCTestCase {
//  /// A transaction which only consumes gas.
//  func testSuccessfulTransaction() {
//    let input = "{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1\",\"counter\":\"31127\",\"gas_limit\":\"100000\",\"storage_limit\":\"10000\",\"amount\":\"1000000\",\"destination\":\"KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":284,\"change\":\"1\"}],\"operation_result\":{\"status\":\"applied\",\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1000000\"},{\"kind\":\"contract\",\"contract\":\"KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka\",\"change\":\"1000000\"}],\"consumed_gas\":\"10200\"}}}]}"
//    guard
//      let inputData = input.data(using: .utf8),
//      let simulationResult = SimulationResultResponseAdapter.parse(input: inputData)
//    else {
//      XCTFail()
//      return
//    }
//
//    guard case .success(let consumedGas, let consumedStorage) = simulationResult else {
//      XCTFail()
//      return
//    }
//
//    XCTAssertEqual(consumedGas, 10_200)
//    XCTAssertEqual(consumedStorage, 0)
//  }
//
//  /// A transaction that consumes gas and storage.
//  func testSuccessfulContractInvocation() {
//    let input = "{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1\",\"counter\":\"31127\",\"gas_limit\":\"100000\",\"storage_limit\":\"10000\",\"amount\":\"0\",\"destination\":\"KT1XsHrcWTmRFGyPgtzEHb4fb9qDAj5oQxwB\",\"parameters\":{\"string\":\"TezosKit\"},\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":284,\"change\":\"1\"}],\"operation_result\":{\"status\":\"applied\",\"storage\":{\"string\":\"TezosKit\"},\"consumed_gas\":\"11780\",\"storage_size\":\"49\"}}}]}"
//    guard
//      let inputData = input.data(using: .utf8),
//      let simulationResult = SimulationResultResponseAdapter.parse(input: inputData)
//      else {
//        XCTFail()
//        return
//    }
//
//    guard case .success(let consumedGas, let consumedStorage) = simulationResult else {
//      XCTFail()
//      return
//    }
//
//    XCTAssertEqual(consumedGas, 11_780)
//    XCTAssertEqual(consumedStorage, 49)
//  }
//
//  /// Failed transaction - attempted to send too many Tez.
//  public func testFailureOperationParameters() {
//    let input = "{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1\",\"counter\":\"31127\",\"gas_limit\":\"100000\",\"storage_limit\":\"10000\",\"amount\":\"10000000000000000\",\"destination\":\"KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":284,\"change\":\"1\"}],\"operation_result\":{\"status\":\"failed\",\"errors\":[{\"kind\":\"temporary\",\"id\":\"proto.004-Pt24m4xi.contract.balance_too_low\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"balance\":\"400570851\",\"amount\":\"10000000000000000\"}]}}}]}"
//    guard
//      let inputData = input.data(using: .utf8),
//      let simulationResult = SimulationResultResponseAdapter.parse(input: inputData)
//      else {
//        XCTFail()
//        return
//    }
//
//    guard case .failure = simulationResult else {
//      XCTFail()
//      return
//    }
//  }
//
//  /// Failed transaction - too low of gas limit
//  public func testFailureExhaustedGas() {
//    let input = "{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1\",\"counter\":\"31127\",\"gas_limit\":\"0\",\"storage_limit\":\"10000\",\"amount\":\"10000000000000000\",\"destination\":\"KT1D5jmrBD7bDa3jCpgzo32FMYmRDdK2ihka\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":284,\"change\":\"1\"}],\"operation_result\":{\"status\":\"failed\",\"errors\":[{\"kind\":\"temporary\",\"id\":\"proto.004-Pt24m4xi.gas_exhausted.operation\"}]}}}]}"
//    guard
//      let inputData = input.data(using: .utf8),
//      let simulationResult = SimulationResultResponseAdapter.parse(input: inputData)
//      else {
//        XCTFail()
//        return
//    }
//
//    guard case .failure = simulationResult else {
//      XCTFail()
//      return
//    }
//  }
//
//  /// A batch transaction.
//  func testBatchTransaction() {
//    let input = "{  \"contents\": [{    \"counter\": \"776970\",    \"fee\": \"1268\",    \"gas_limit\": \"10000\",    \"kind\": \"reveal\",    \"metadata\": {      \"balance_updates\": [{        \"change\": \"-1268\",        \"contract\": \"tz1WwEvjKxdz1EFa6a7HYP14SwZSPGfFnPuc\",        \"kind\": \"contract\"      }, {        \"category\": \"fees\",        \"change\": \"1268\",        \"cycle\": 290,        \"delegate\": \"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",        \"kind\": \"freezer\"      }],      \"operation_result\": {        \"consumed_gas\": \"10000\",        \"status\": \"applied\"}    },    \"public_key\": \"edpkuG12SJVcmdNxWfXKPb24mNXSxFX4jsDPYPG7r5AwqdG5G7aACZ\",    \"source\": \"tz1WwEvjKxdz1EFa6a7HYP14SwZSPGfFnPuc\",\"storage_limit\": \"0\"}, {    \"counter\": \"776971\",    \"delegate\": \"tz1WwEvjKxdz1EFa6a7HYP14SwZSPGfFnPuc\",\"fee\": \"0\", \"gas_limit\": \"800000\", \"kind\": \"delegation\",\"metadata\": {\"balance_updates\": [],\"operation_result\": {\"consumed_gas\": \"10000\",\"status\": \"applied\"}},\"source\": \"tz1WwEvjKxdz1EFa6a7HYP14SwZSPGfFnPuc\",\"storage_limit\": \"60000\"}]}"
//    guard
//      let inputData = input.data(using: .utf8),
//      let simulationResult = SimulationResultResponseAdapter.parse(input: inputData)
//    else {
//        XCTFail()
//        return
//    }
//
//    guard case .success(let consumedGas, let consumedStorage) = simulationResult else {
//      XCTFail()
//      return
//    }
//
//    XCTAssertEqual(consumedGas, 20_000)
//    XCTAssertEqual(consumedStorage, 0)
//  }
//
//  func testInternalTransactionS() {
//    let input = "{ \"contents\": [ { \"kind\": \"transaction\", \"source\": \"tz1XarY7qEahQBipuuNZ4vPw9MN6Ldyxv8G3\", \"fee\": \"0\", \"counter\": \"30631\", \"gas_limit\": \"800000\", \"storage_limit\": \"60000\", \"amount\": \"10000000\", \"destination\": \"KT1RrfbcDM5eqho4j4u5EbqbaoEFwBsXA434\", \"parameters\": { \"prim\": \"Right\", \"args\": [ { \"prim\": \"Left\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"int\": \"1\" }, { \"string\": \"2020-06-29T18:00:21Z\" } ] } ] } ] }, \"metadata\": { \"balance_updates\": [], \"operation_result\": { \"status\": \"applied\", \"storage\": { \"prim\": \"Pair\", \"args\": [ [], { \"prim\": \"Pair\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"bytes\": \"019177bfab48c1e9991fca5f7ca6ebe99a1aa5cf5700\" }, { \"bytes\": \"018f090483da68845c926fff0e360a1154266c994b00\" } ] }, { \"prim\": \"Pair\", \"args\": [ { \"int\": \"19352385\" }, [ { \"prim\": \"Elt\", \"args\": [ { \"bytes\": \"00008307c8ce77c8f7ab711c1d3bb3570e5fbe11f5dc\" }, { \"prim\": \"Right\", \"args\": [ { \"prim\": \"Left\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"int\": \"1\" }, { \"int\": \"1593453621\" } ] } ] } ] } ] } ] ] } ] } ] }, \"big_map_diff\": [], \"balance_updates\": [ { \"kind\": \"contract\", \"contract\": \"tz1XarY7qEahQBipuuNZ4vPw9MN6Ldyxv8G3\", \"change\": \"-10000000\" }, { \"kind\": \"contract\", \"contract\": \"KT1RrfbcDM5eqho4j4u5EbqbaoEFwBsXA434\", \"change\": \"10000000\" } ], \"consumed_gas\": \"185075\", \"storage_size\": \"7166\" }, \"internal_operation_results\": [ { \"kind\": \"transaction\", \"source\": \"KT1RrfbcDM5eqho4j4u5EbqbaoEFwBsXA434\", \"nonce\": 0, \"amount\": \"10000000\", \"destination\": \"KT1MqvzsEPoZnbacH18uztqvQdG8x8nKAgFi\", \"parameters\": { \"prim\": \"Left\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"bytes\": \"01bd7bcfca7caa3469dfa1a0bf4863dc8de759de6b00\" }, { \"bytes\": \"018f090483da68845c926fff0e360a1154266c994b00\" } ] } ] }, \"result\": { \"status\": \"applied\", \"storage\": { \"prim\": \"Pair\", \"args\": [ [], { \"prim\": \"Unit\" } ] }, \"big_map_diff\": [ { \"key_hash\": \"exprv3WzhTyQcC4ZmG66wfxsLYy9im9Pe8msAGxnLSdRE16QEvxHhj\", \"key\": { \"bytes\": \"018f090483da68845c926fff0e360a1154266c994b00\" }, \"value\": { \"prim\": \"Pair\", \"args\": [ { \"int\": \"10000000\" }, { \"bytes\": \"01bd7bcfca7caa3469dfa1a0bf4863dc8de759de6b00\" } ] } } ], \"balance_updates\": [ { \"kind\": \"contract\", \"contract\": \"KT1RrfbcDM5eqho4j4u5EbqbaoEFwBsXA434\", \"change\": \"-10000000\" }, { \"kind\": \"contract\", \"contract\": \"KT1MqvzsEPoZnbacH18uztqvQdG8x8nKAgFi\", \"change\": \"10000000\" } ], \"consumed_gas\": \"145880\", \"storage_size\": \"826\" } }, { \"kind\": \"transaction\", \"source\": \"KT1MqvzsEPoZnbacH18uztqvQdG8x8nKAgFi\", \"nonce\": 1, \"amount\": \"0\", \"destination\": \"KT1Md4zkfCvkdqgxAC9tyRYpRUBKmD1owEi2\", \"parameters\": { \"prim\": \"Right\", \"args\": [ { \"bytes\": \"01bd7bcfca7caa3469dfa1a0bf4863dc8de759de6b00\" } ] }, \"result\": { \"status\": \"applied\", \"storage\": { \"prim\": \"Pair\", \"args\": [ [], { \"prim\": \"Pair\", \"args\": [ { \"int\": \"100\" }, { \"prim\": \"Pair\", \"args\": [ { \"string\": \"Tezos Gold\" }, { \"string\": \"TGD\" } ] } ] } ] }, \"big_map_diff\": [], \"consumed_gas\": \"49771\", \"storage_size\": \"784\" } }, { \"kind\": \"transaction\", \"source\": \"KT1Md4zkfCvkdqgxAC9tyRYpRUBKmD1owEi2\", \"nonce\": 2, \"amount\": \"0\", \"destination\": \"KT1MqvzsEPoZnbacH18uztqvQdG8x8nKAgFi\", \"parameters\": { \"prim\": \"Right\", \"args\": [ { \"int\": \"12\" } ] }, \"result\": { \"status\": \"applied\", \"storage\": { \"prim\": \"Pair\", \"args\": [ [], { \"prim\": \"Unit\" } ] }, \"big_map_diff\": [], \"consumed_gas\": \"134614\", \"storage_size\": \"826\" } }, { \"kind\": \"transaction\", \"source\": \"KT1MqvzsEPoZnbacH18uztqvQdG8x8nKAgFi\", \"nonce\": 3, \"amount\": \"10000000\", \"destination\": \"KT1RrfbcDM5eqho4j4u5EbqbaoEFwBsXA434\", \"parameters\": { \"prim\": \"Right\", \"args\": [ { \"prim\": \"Right\", \"args\": [ { \"prim\": \"Right\", \"args\": [ { \"int\": \"12\" } ] } ] } ] }, \"result\": { \"status\": \"applied\", \"storage\": { \"prim\": \"Pair\", \"args\": [ [], { \"prim\": \"Pair\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"bytes\": \"019177bfab48c1e9991fca5f7ca6ebe99a1aa5cf5700\" }, { \"bytes\": \"018f090483da68845c926fff0e360a1154266c994b00\" } ] }, { \"prim\": \"Pair\", \"args\": [ { \"int\": \"19352385\" }, [] ] } ] } ] }, \"big_map_diff\": [], \"balance_updates\": [ { \"kind\": \"contract\", \"contract\": \"KT1MqvzsEPoZnbacH18uztqvQdG8x8nKAgFi\", \"change\": \"-10000000\" }, { \"kind\": \"contract\", \"contract\": \"KT1RrfbcDM5eqho4j4u5EbqbaoEFwBsXA434\", \"change\": \"10000000\" } ], \"consumed_gas\": \"187633\", \"storage_size\": \"7123\" } }, { \"kind\": \"transaction\", \"source\": \"KT1RrfbcDM5eqho4j4u5EbqbaoEFwBsXA434\", \"nonce\": 4, \"amount\": \"0\", \"destination\": \"KT1Md4zkfCvkdqgxAC9tyRYpRUBKmD1owEi2\", \"parameters\": { \"prim\": \"Left\", \"args\": [ { \"prim\": \"Pair\", \"args\": [ { \"bytes\": \"01bd7bcfca7caa3469dfa1a0bf4863dc8de759de6b00\" }, { \"prim\": \"Pair\", \"args\": [ { \"bytes\": \"00008307c8ce77c8f7ab711c1d3bb3570e5fbe11f5dc\" }, { \"int\": \"1\" } ] } ] } ] }, \"result\": { \"status\": \"applied\", \"storage\": { \"prim\": \"Pair\", \"args\": [ [], { \"prim\": \"Pair\", \"args\": [ { \"int\": \"100\" }, { \"prim\": \"Pair\", \"args\": [ { \"string\": \"Tezos Gold\" }, { \"string\": \"TGD\" } ] } ] } ] }, \"big_map_diff\": [ { \"key_hash\": \"exprtoyixHUj8qCQE23RH3AG7ScoFMeafLGxc93M8XZZ4ckJYr2JpQ\", \"key\": { \"bytes\": \"00008307c8ce77c8f7ab711c1d3bb3570e5fbe11f5dc\" }, \"value\": { \"prim\": \"Pair\", \"args\": [ { \"int\": \"58\" }, [] ] } }, { \"key_hash\": \"exprv9SUvRRcsRJRGD8tHmKVbPNxWQ71hK6LNRCXVjkTw8pd8GRkUB\", \"key\": { \"bytes\": \"01bd7bcfca7caa3469dfa1a0bf4863dc8de759de6b00\" }, \"value\": { \"prim\": \"Pair\", \"args\": [ { \"int\": \"11\" }, [] ] } } ], \"consumed_gas\": \"30827\", \"storage_size\": \"784\" } } ] } } ] }"
//    guard
//      let inputData = input.data(using: .utf8),
//      let simulationResult = SimulationResultResponseAdapter.parse(input: inputData)
//      else {
//        XCTFail()
//        return
//    }
//
//    guard case .success(let consumedGas, let consumedStorage) = simulationResult else {
//      XCTFail()
//      return
//    }
//
//    XCTAssertEqual(consumedGas, 733_800)
//    XCTAssertEqual(consumedStorage, 17_509)
//  }
}
