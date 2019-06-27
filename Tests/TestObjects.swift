// Copyright Keefer Taylor, 2019.

import Foundation

import TezosCrypto
@testable import TezosKit

/// Extensions to classes to provide static objects for testing.

extension String {
  public static let testChainID = "abc"
  public static let testBranch = "xyz"
  public static let testProtocol = "alpha"
  public static let testKey = "123"
  public static let testSignature = "abc123signature"
  public static let testAddress = "tz1abc123xyz"
  public static let testDestinationAddress = "tz1destination"
  public static let testForgeResult = "test_forge_result"
}

extension Int {
  public static let testAddressCounter = 0
}

extension FakePublicKey {
  public static let testPublicKey = FakePublicKey(base58CheckRepresentation: "public_key_base_58")
}

extension Array where Element == UInt8 {
  public static let testSignature: [UInt8] = [1, 2, 3]
}

extension OperationMetadata {
  public static let testOperationMetadata = OperationMetadata(
    chainID: .testChainID,
    branch: .testBranch,
    protocol: .testProtocol,
    addressCounter: .testAddressCounter,
    key: .testKey
  )
}

extension OperationPayload {
  public static let testOperationPayload = OperationPayload(
    operations: [],
    operationMetadata: .testOperationMetadata
  )
}

extension SignedOperationPayload {
  public static let testSignedOperationPayload = SignedOperationPayload(
    operationPayload: .testOperationPayload,
    signature: .testSignature
  )!
}

extension SignedProtocolOperationPayload {
  public static let testSignedProtocolOperationPayload = SignedProtocolOperationPayload(
    signedOperationPayload: .testSignedOperationPayload,
    operationMetadata: .testOperationMetadata
  )
}

extension AbstractOperation {
  public static let testOperation = AbstractOperation(
    source: .testAddress,
    kind: .reveal,
    operationFees: OperationFees.testFees
  )
}

extension OperationWithCounter {
  public static let testOperationWithCounter = OperationWithCounter(
    operation: AbstractOperation.testOperation,
    counter: .testAddressCounter
  )
}

extension Transaction {
  public static let testTransaction = Transaction(
    source: "tz1MXFrtZoaXckE41bjUCSjAjAap3AFDSr3N",
    destination: "tz1W1en9UpMCH4ZJL8wQCh8JDKCZARyVx2co",
    amount: Tez(1.0),
    fee: Tez(2.0),
    timestamp: 1_234_567,
    blockHash: "BMc3kxPnn95TxYKVPehmYWXuaoKBneoPKeDk4sz7usFp7Aumnez",
    blockLevel: 323_100,
    operationGroupHash: "opMiJzXJV8nKWy7VTLh2yxFL8yUGDpVkvnbA5hUwj9dSnpMEEMa",
    operationID: 1_511_646,
    parameters: nil
  )
}

extension OperationFactory {
  public static let testFactory = OperationFactory()
}

extension OperationFees {
  public static let testFees = OperationFees(
    fee: Tez.zeroBalance,
    gasLimit: Tez.zeroBalance,
    storageLimit: Tez.zeroBalance
  )
}

extension TimeInterval {
  public static let expectationTimeout = 0.1
}

extension Wallet {
  public static let testWallet =
    Wallet(mnemonic: "predict corn duty process brisk tomato shrimp virtual horror half rhythm cook")!
}

// swiftlint:disable line_length

extension FakeNetworkClient {
  public static let conseilMap: [String: String] = [
    "operations": "[{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551211288000,\"pkh\":null,\"nonce\":null,\"block_level\":201258,\"balance\":null,\"operation_group_hash\":\"ooUac4yq9AhwCEzSXVyXSQNvNUsjNBTBFzZGbkq7wJkaVU4iDEW\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BKxAQREmpuwGUe72q5igf4hHXFELRpG7BpokCMnik7nxDRz7eFY\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1511180,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30609,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551300808000,\"pkh\":null,\"nonce\":null,\"block_level\":203502,\"balance\":null,\"operation_group_hash\":\"onwNtnGgZnE4ibA8C9FLKythCu3Vh2u8X1pLBBBTjXt3tJgCUYb\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BLJ8VD8tLs56AnwHAys4jKfPjFncX7rfQPww7CofVmeNenngKzP\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1528488,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30610,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551300938000,\"pkh\":null,\"nonce\":null,\"block_level\":203505,\"balance\":null,\"operation_group_hash\":\"ooQ8kE6MywRGTkVpxd35cVYhXC5ndteZfMqCzFSPSrb1ebNicp3\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BLNnxJHyjUSKr1CNq3qT29Gjfy3SzUC1RauAKLKVEcQjuwefRFS\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1528496,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30613,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551300838000,\"pkh\":null,\"nonce\":null,\"block_level\":203503,\"balance\":null,\"operation_group_hash\":\"ooKAS3wDT9HFWgQMzw3LqXNpikYCyK2DL5rp17pHtWrBSZxX9ik\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BLgh1F855itRPX18aVWYY8CkgSoiq76R7pSkAYvsLkt4qDNyHZu\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1528558,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30611,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null},{\"secret\":null,\"storage_size\":null,\"delegatable\":null,\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"consumed_gas\":10100,\"timestamp\":1551300868000,\"pkh\":null,\"nonce\":null,\"block_level\":203504,\"balance\":null,\"operation_group_hash\":\"ooKJAu5CnTJqtiLcDvzaS4JsDb9pX4Lg8Fzm7qCBRe2Jxh5EyF4\",\"public_key\":null,\"paid_storage_size_diff\":null,\"amount\":1,\"delegate\":null,\"block_hash\":\"BLb7Tbfp6rMTen9uPeu2nP3ifMdaVgztjaHFgeWWtnGodU677Dq\",\"spendable\":null,\"status\":\"applied\",\"operation_id\":1528591,\"manager_pubkey\":null,\"slots\":null,\"storage_limit\":257,\"storage\":null,\"counter\":30612,\"script\":null,\"kind\":\"transaction\",\"gas_limit\":10100,\"parameters\":null,\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"fee\":1272,\"level\":null}]"
  ]

  public static let conseilClient = FakeNetworkClient(endpointToResponseMap: conseilMap)
}

// swiftlint:enable line_length
