// Copyright Keefer Taylor, 2019

@testable import TezosKit
import XCTest

final class ConseilClientTests: XCTestCase {

  // swiftlint:disable line_length
  func testSent() {
    let endpointToResponseMap = [
      "operations": "[{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551211288000,\"pkh\":null,\"nonce\":null,\"block_level\":201258,\"balance\":null,\"operation_group_hash\":\"ooUac4yq9AhwCEzSXVyXSQNvNUsjNBTBFzZGbkq7wJkaVU4iDEW\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BKxAQREmpuwGUe72q5igf4hHXFELRpG7BpokCMnik7nxDRz7eFY\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1511180,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30609,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551300808000,\"pkh\":null,\"nonce\":null,\"block_level\":203502,\"balance\":null,\"operation_group_hash\":\"onwNtnGgZnE4ibA8C9FLKythCu3Vh2u8X1pLBBBTjXt3tJgCUYb\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BLJ8VD8tLs56AnwHAys4jKfPjFncX7rfQPww7CofVmeNenngKzP\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1528488,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30610,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551300938000,\"pkh\":null,\"nonce\":null,\"block_level\":203505,\"balance\":null,\"operation_group_hash\":\"ooQ8kE6MywRGTkVpxd35cVYhXC5ndteZfMqCzFSPSrb1ebNicp3\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BLNnxJHyjUSKr1CNq3qT29Gjfy3SzUC1RauAKLKVEcQjuwefRFS\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1528496,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30613,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551300838000,\"pkh\":null,\"nonce\":null,\"block_level\":203503,\"balance\":null,\"operation_group_hash\":\"ooKAS3wDT9HFWgQMzw3LqXNpikYCyK2DL5rp17pHtWrBSZxX9ik\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BLgh1F855itRPX18aVWYY8CkgSoiq76R7pSkAYvsLkt4qDNyHZu\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1528558,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30611,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551300868000,\"pkh\":null,\"nonce\":null,\"block_level\":203504,\"balance\":null,\"operation_group_hash\":\"ooKJAu5CnTJqtiLcDvzaS4JsDb9pX4Lg8Fzm7qCBRe2Jxh5EyF4\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BLb7Tbfp6rMTen9uPeu2nP3ifMdaVgztjaHFgeWWtnGodU677Dq\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1528591,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30612,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null}]"
    ]
    let fakeNetworkClient = FakeNetworkClient(endpointToResponseMap: endpointToResponseMap)
    let conseilClient = ConseilClient(networkClient: fakeNetworkClient)

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

  func testReceived() {
    let endpointToResponseMap = [
      "operations": "[{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XarY7qEahQBipuuNZ4vPw9MN6Ldyxv8G3\",\"consumed_gas\":10100,\"timestamp\":1551209728000,\"pkh\":null,\"nonce\":null,\"block_level\":201218,\"balance\":null,\"operation_group_hash\":\"opLSsVD642nyYEgWjdBMiB57Ve8SyfC9eqVxvkhF2S1CcYvNSDL\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":100000000,\"delegate\":null,\"block_hash\":\"BMUuTBSuFiukz3nTJyeABK54xSsfLbq2cTaU71X3S6crTczqXAM\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1511036,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":277,\"storage\":null,\"counter\":30607,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10200,\"parameters\":null,\"destination\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":1180,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XarY7qEahQBipuuNZ4vPw9MN6Ldyxv8G3\",\"consumed_gas\":10100,\"timestamp\":1553554768000,\"pkh\":null,\"nonce\":null,\"block_level\":260094,\"balance\":null,\"operation_group_hash\":\"onkueUfux4wxJiJJDt9LEchx8zs14eCz5Kh9sndi3JZ3C36Q9U4\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1000000000,\"delegate\":null,\"block_hash\":\"BLWJkHRv4697WmGJ8mAabG4eXX5kqZMaY9tZRQ8ufdpYbRbE4K4\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1975613,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":0,\"storage\":null,\"counter\":30608,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10200,\"parameters\":null,\"destination\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":1277,\"level\":null}]"
    ]
    let fakeNetworkClient = FakeNetworkClient(endpointToResponseMap: endpointToResponseMap)
    let conseilClient = ConseilClient(networkClient: fakeNetworkClient)

    let expectation = XCTestExpectation(description: "completion called")
    conseilClient.transactionsReceived(from: Wallet.testWallet.address) { result in
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

  func testTransactions() {
    let endpointToResponseMap = [
      "operations": "[{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551211288000,\"pkh\":null,\"nonce\":null,\"block_level\":201258,\"balance\":null,\"operation_group_hash\":\"ooUac4yq9AhwCEzSXVyXSQNvNUsjNBTBFzZGbkq7wJkaVU4iDEW\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BKxAQREmpuwGUe72q5igf4hHXFELRpG7BpokCMnik7nxDRz7eFY\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1511180,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30609,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551300808000,\"pkh\":null,\"nonce\":null,\"block_level\":203502,\"balance\":null,\"operation_group_hash\":\"onwNtnGgZnE4ibA8C9FLKythCu3Vh2u8X1pLBBBTjXt3tJgCUYb\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BLJ8VD8tLs56AnwHAys4jKfPjFncX7rfQPww7CofVmeNenngKzP\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1528488,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30610,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551300938000,\"pkh\":null,\"nonce\":null,\"block_level\":203505,\"balance\":null,\"operation_group_hash\":\"ooQ8kE6MywRGTkVpxd35cVYhXC5ndteZfMqCzFSPSrb1ebNicp3\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BLNnxJHyjUSKr1CNq3qT29Gjfy3SzUC1RauAKLKVEcQjuwefRFS\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1528496,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30613,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null}]"
    ]
    let fakeNetworkClient = FakeNetworkClient(endpointToResponseMap: endpointToResponseMap)
    let conseilClient = ConseilClient(networkClient: fakeNetworkClient)

    let expectation = XCTestExpectation(description: "completion called")
    conseilClient.transactions(from: Wallet.testWallet.address) { result in
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

  func testOriginatedAccounts() {
    let endpointToResponseMap = [
      "accounts": "[{\"block_level\":470787,\"balance\":764490964,\"delegate_value\":null,\"spendable\":true,\"account_id\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"manager\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"storage\":null,\"counter\":30970,\"block_id\":\"BMPZoKmUG3JGFgd6Vhef35Z85bTWB1NcPg1iNZFNQNWFPEgrk3Q\",\"script\":null,\"delegate_setable\":false},{\"block_level\":470784,\"balance\":0,\"delegate_value\":null,\"spendable\":true,\"account_id\":\"KT1VCQ6gLdV8LQBxnawMv6tfeGxfKQq1W3tW\",\"manager\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"storage\":null,\"counter\":0,\"block_id\":\"BMLaEgYNHqPAjBDEV1Ctz4JsZXHmz1rFH6kz3PVoq6gabMdNBDd\",\"script\":null,\"delegate_setable\":true}]"
    ]
    let fakeNetworkClient = FakeNetworkClient(endpointToResponseMap: endpointToResponseMap)
    let conseilClient = ConseilClient(networkClient: fakeNetworkClient)

    let expectation = XCTestExpectation(description: "completion called")
    conseilClient.originatedAccounts(from: Wallet.testWallet.address) { result in
      switch result {
      case .success(let results):
        XCTAssert(results.count > 1)
        expectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    wait(for: [expectation], timeout: .expectationTimeout)
  }

  func testOriginatedContracts() {
    let endpointToResponseMap = [
      "accounts": "[{\"block_level\":244028,\"balance\":0,\"delegate_value\":null,\"spendable\":false,\"account_id\":\"KT1M9akk89aUpCFy3ajDUEzsoMuAvrEzzNzB\",\"manager\":\"tz1RYq8wjcCbRZykY7XH15WPkzK7TWwPvJJt\",\"storage\":\"Unparsable code: {\\\"int\\\":\\\"0\\\"}\",\"counter\":0,\"block_id\":\"BMWoYyYjrPZgao6H4o4EA3xrNsvKhSMvzRUFu77MwSXLvNokJx6\",\"script\":\"parameter bytes;\\nstorage nat;\\ncode { DUP ;\\n       DIP { CDR @storage_slash_8 } ;\\n       CAR @parameter_slash_9 ;\\n       DUP @parameter ;\\n       UNPACK (pair string bytes) ;\\n       IF_NONE { PUSH string \\\"Cannot unpack bytes\\\" ;\\n                 FAILWITH }\\n               { DUP @_called_function_argument ;\\n                 CDR @argument ;\\n                 UNPACK (pair address (pair address (pair string (pair nat (pair string (pair address address)))))) ;\\n                 IF_NONE { PUSH string \\\"Cannot unpack bytes\\\" ;\\n                           FAILWITH }\\n                         { PUSH @dest1 (contract :Sachets (pair address (pair string (pair nat (pair string (pair (contract :LiqidPool (pair (contract :Assets (or :_entries (bytes %_Liq_entry_assets_cb) (or (unit %_Liq_entry_assets_list) (or (nat %_Liq_entry_assets_add) (or (nat %_Liq_entry_assets_remove) (or (nat %_Liq_entry_assets_buy) (nat %_Liq_entry_assets_updatePrice))))))) (pair string (pair nat address)))) (contract :Assets (or :_entries (bytes %_Liq_entry_assets_cb) (or (unit %_Liq_entry_assets_list) (or (nat %_Liq_entry_assets_add) (or (nat %_Liq_entry_assets_remove) (or (nat %_Liq_entry_assets_buy) (nat %_Liq_entry_assets_updatePrice))))))))))))) \\\"KT1B9gFEdZ6p3SWyaweGfYUUuA7ayBrQ7sLM\\\" ;\\n                           PUSH mutez 0 ;\\n                           PUSH @param2 (contract :Assets (or :_entries (bytes %_Liq_entry_assets_cb) (or (unit %_Liq_entry_assets_list) (or (nat %_Liq_entry_assets_add) (or (nat %_Liq_entry_assets_remove) (or (nat %_Liq_entry_assets_buy) (nat %_Liq_entry_assets_updatePrice))))))) \\\"KT1JHhRj3gfw9p4BMsx1wEg5StUwCezbh4NC\\\" ;\\n                           PUSH @param1 (contract :LiqidPool (pair (contract :Assets (or :_entries (bytes %_Liq_entry_assets_cb) (or (unit %_Liq_entry_assets_list) (or (nat %_Liq_entry_assets_add) (or (nat %_Liq_entry_assets_remove) (or (nat %_Liq_entry_assets_buy) (nat %_Liq_entry_assets_updatePrice))))))) (pair string (pair nat address)))) \\\"KT1WpB3Lys3FZ5tMxtNKVNRyMDUTcWKu57AL\\\" ;\\n                           PAIR ;\\n                           { DIP { { DIP { { DIP { DUP } ; SWAP } } ; SWAP } } ; SWAP } ;\\n                           { CDR ; CDR ; CDR ; CDR ; CAR @sachets_id } ;\\n                           PAIR ;\\n                           { DIP { { DIP { { DIP { DUP } ; SWAP } } ; SWAP } } ; SWAP } ;\\n                           { CDR ; CDR ; CDR ; CAR @quantity } ;\\n                           PAIR ;\\n                           { DIP { { DIP { { DIP { DUP } ; SWAP } } ; SWAP } } ; SWAP } ;\\n                           { CDR ; CDR ; CAR @asset_id } ;\\n                           PAIR ;\\n                           { DIP { { DIP { { DIP { DUP } ; SWAP } } ; SWAP } } ; SWAP } ;\\n                           DIP { DIP { DIP { DIP { DROP } } } } ;\\n                           { CDR ; CAR @user_id } ;\\n                           PAIR ;\\n                           TRANSFER_TOKENS @op ;\\n                           { DIP { { DIP { { DIP { DUP } ; SWAP } } ; SWAP } } ; SWAP } ;\\n                           NIL operation ;\\n                           { DIP { { DIP { DUP } ; SWAP } } ; SWAP } ;\\n                           DIP { DIP { DIP { DROP } } } ;\\n                           CONS ;\\n                           PAIR } ;\\n                 DIP { DROP } } ;\\n       DIP { DROP ; DROP } }\",\"delegate_setable\":false},{\"block_level\":244013,\"balance\":0,\"delegate_value\":null,\"spendable\":false,\"account_id\":\"KT1Q1E5PEiL7t7YgZ2TZ2spJq2J75Cf6exok\",\"manager\":\"tz1RYq8wjcCbRZykY7XH15WPkzK7TWwPvJJt\",\"storage\":\"Unparsable code: {\\\"int\\\":\\\"0\\\"}\",\"counter\":0,\"block_id\":\"BLwjdMy3R2r7CQPkonZbqUBWaE788rbYgAJp4z37TBHLyAG9jtH\",\"script\":\"parameter bytes;\\nstorage nat;\\ncode { DUP ;\\n       DIP { CDR @storage_slash_8 } ;\\n       CAR @parameter_slash_9 ;\\n       DUP @parameter ;\\n       UNPACK (pair string bytes) ;\\n       IF_NONE { PUSH string \\\"Cannot unpack bytes\\\" ;\\n                 FAILWITH }\\n               { { DIP { { DIP { DUP @storage } ; SWAP } } ; SWAP } ;\\n                 NIL operation ;\\n                 { DIP { { DIP { DUP @_called_function_argument } ; SWAP } } ; SWAP } ;\\n                 CDR @argument ;\\n                 DUP @params ;\\n                 UNPACK (pair address (pair address (pair string (pair nat (pair string (pair address address)))))) ;\\n                 IF_NONE { PUSH string \\\"Cannot unpack bytes\\\" ;\\n                           FAILWITH }\\n                         { PUSH @dest1 (contract :Sachets (pair address (pair string (pair nat (pair string (pair (contract :LiqidPool (pair (contract :Assets (or :_entries (bytes %_Liq_entry_assets_cb) (or (unit %_Liq_entry_assets_list) (or (nat %_Liq_entry_assets_add) (or (nat %_Liq_entry_assets_remove) (or (nat %_Liq_entry_assets_buy) (nat %_Liq_entry_assets_updatePrice))))))) (pair string (pair nat address)))) (contract :Assets (or :_entries (bytes %_Liq_entry_assets_cb) (or (unit %_Liq_entry_assets_list) (or (nat %_Liq_entry_assets_add) (or (nat %_Liq_entry_assets_remove) (or (nat %_Liq_entry_assets_buy) (nat %_Liq_entry_assets_updatePrice))))))))))))) \\\"KT1Mq3C58Y7xkdDXtRnwSRWjH3mfFN2nqmfu\\\" ;\\n                           PUSH mutez 0 ;\\n                           PUSH @param2 (contract :Assets (or :_entries (bytes %_Liq_entry_assets_cb) (or (unit %_Liq_entry_assets_list) (or (nat %_Liq_entry_assets_add) (or (nat %_Liq_entry_assets_remove) (or (nat %_Liq_entry_assets_buy) (nat %_Liq_entry_assets_updatePrice))))))) \\\"KT1JHhRj3gfw9p4BMsx1wEg5StUwCezbh4NC\\\" ;\\n                           PUSH @param1 (contract :LiqidPool (pair (contract :Assets (or :_entries (bytes %_Liq_entry_assets_cb) (or (unit %_Liq_entry_assets_list) (or (nat %_Liq_entry_assets_add) (or (nat %_Liq_entry_assets_remove) (or (nat %_Liq_entry_assets_buy) (nat %_Liq_entry_assets_updatePrice))))))) (pair string (pair nat address)))) \\\"KT1HEByN5eu7MKVfpB5iSV4ML3XovBkNPhx9\\\" ;\\n                           PAIR ;\\n                           { DIP { { DIP { { DIP { DUP } ; SWAP } } ; SWAP } } ; SWAP } ;\\n                           { CDR ; CDR ; CDR ; CDR ; CAR @sachets_id } ;\\n                           PAIR ;\\n                           { DIP { { DIP { { DIP { DUP } ; SWAP } } ; SWAP } } ; SWAP } ;\\n                           { CDR ; CDR ; CDR ; CAR @quantity } ;\\n                           PAIR ;\\n                           { DIP { { DIP { { DIP { DUP } ; SWAP } } ; SWAP } } ; SWAP } ;\\n                           { CDR ; CDR ; CAR @asset_id } ;\\n                           PAIR ;\\n                           { DIP { { DIP { { DIP { DUP } ; SWAP } } ; SWAP } } ; SWAP } ;\\n                           DIP { DIP { DIP { DIP { DROP } } } } ;\\n                           { CDR ; CAR @user_id } ;\\n                           PAIR ;\\n                           TRANSFER_TOKENS @op } ;\\n                 DIP { DROP } ;\\n                 DIP { DIP { DIP { DROP } } } ;\\n                 CONS ;\\n                 PAIR } ;\\n       DIP { DROP ; DROP } }\",\"delegate_setable\":false}]"
    ]
    let fakeNetworkClient = FakeNetworkClient(endpointToResponseMap: endpointToResponseMap)
    let conseilClient = ConseilClient(networkClient: fakeNetworkClient)

    let expectation = XCTestExpectation(description: "completion called")
    conseilClient.originatedContracts(from: Wallet.testWallet.address) { result in
      switch result {
      case .success(let results):
        XCTAssert(results.count > 1)
        expectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    wait(for: [expectation], timeout: .expectationTimeout)
  }

  // swiftlint:enable line_length

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
