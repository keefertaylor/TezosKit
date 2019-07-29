// Copyright Keefer Taylor, 2019.

import Foundation

import TezosCrypto
@testable import TezosKit

/// Extensions to classes to provide static objects for testing.

extension String {
  public static let testBranch = "xyz"
  public static let testProtocol = "alpha"
  public static let testSignature = "edsigabc123"
  public static let testAddress = "tz1abc123xyz"
  public static let testDestinationAddress = "tz1destination"
  public static let testForgeResult = "test_forge_result"
  public static let testPublicKey = "edpk_test"
  public static let testSignedBytesForInjection = "abc123edsigxyz789"
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
    branch: .testBranch,
    protocol: .testProtocol,
    addressCounter: .testAddressCounter,
    key: .testPublicKey
  )
}

extension FakeSignatureProvider {
  public static let testSignatureProvider = FakeSignatureProvider(
    signature: .testSignature,
    publicKey: FakePublicKey.testPublicKey
  )
}

extension OperationPayload {
  public static let testOperationPayload = OperationPayload(
    operations: [],
    operationFactory: OperationFactory(),
    operationMetadata: .testOperationMetadata,
    source: .testAddress,
    signatureProvider: FakeSignatureProvider.testSignatureProvider
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
    fee: Tez(1.0),
    gasLimit: 200,
    storageLimit: 300
  )
}

extension TimeInterval {
  public static let expectationTimeout = 0.1
}

extension Wallet {
  public static let testWallet =
    Wallet(mnemonic: "predict corn duty process brisk tomato shrimp virtual horror half rhythm cook")!
}

extension OperationMetadataProvider {
  public static let testOperationMetadataProvider =
    OperationMetadataProvider(networkClient: FakeNetworkClient.tezosNodeNetworkClient)
}

extension Dictionary where Key == String, Value == String {
  public static let managerKeyResponse: [String: String] = [
    OperationMetadataProvider.JSON.Keys.key: .testPublicKey
  ]
  public static let headResponse: [String: String]  = [
    OperationMetadataProvider.JSON.Keys.protocol: .testProtocol,
    OperationMetadataProvider.JSON.Keys.hash: .testBranch
  ]
}

// swiftlint:disable line_length

extension FakeNetworkClient {
  private static let tezosNodeClientEndpointToResponseMap = [
    "/chains/main/blocks/xyz/helpers/forge/operations": JSONUtils.jsonString(for: .testForgeResult)!,
    "/chains/main/blocks/head/context/contracts/" + .testAddress + "/counter": JSONUtils.jsonString(for: Int.testAddressCounter)!,
    "/chains/main/blocks/head/context/contracts/" + .testAddress + "/manager_key": JSONUtils.jsonString(for: .managerKeyResponse)!,
    "/chains/main/blocks/head": JSONUtils.jsonString(for: .headResponse)!,
    "/chains/main/blocks/" + .testBranch + "/helpers/preapply/operations": "[{\"contents\":[{\"kind\":\"transaction\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1272\",\"counter\":\"30801\",\"gas_limit\":\"10100\",\"storage_limit\":\"257\",\"amount\":\"1\",\"destination\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1272\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"level\":125,\"change\":\"1272\"}],\"operation_result\":{\"status\":\"applied\",\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1\"},{\"kind\":\"contract\",\"contract\":\"tz3WXYtyDUNL91qfiCJtVUX746QpNv5i5ve5\",\"change\":\"1\"}],\"consumed_gas\":\"10100\"}}}],\"signature\":\"edsigtpsh2VpWyZTZ46q9j54VfsWZLZuxL7UGEhfgCNx6SXwaWu4gMHx59bRdogbSmDCCpXeQeighgpHk5x32k3rtFu8w5EZyEr\"}]\n",
    "/chains/main/blocks/head/helpers/scripts/run_operation": "{\"contents\":[{\"kind\":\"origination\",\"source\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"fee\":\"1265\",\"counter\":\"31038\",\"gas_limit\":\"10000\",\"storage_limit\":\"257\",\"manager_pubkey\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"balance\":\"0\",\"metadata\":{\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-1265\"},{\"kind\":\"freezer\",\"category\":\"fees\",\"delegate\":\"tz1Ke2h7sDdakHJQh8WX4Z372du1KChsksyU\",\"cycle\":247,\"change\":\"1265\"}],\"operation_result\":{\"status\":\"applied\",\"balance_updates\":[{\"kind\":\"contract\",\"contract\":\"tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW\",\"change\":\"-257000\"}],\"originated_contracts\":[\"KT1RAHAXehUNusndqZpcxM8SfCjLi83utZsR\"],\"consumed_gas\":\"10000\"}}}]}\n",
    "/injection/operation": "\"ooTransactionHash\""
  ]

  public static let tezosNodeNetworkClient =
    FakeNetworkClient(endpointToResponseMap: tezosNodeClientEndpointToResponseMap)
}

// swiftlint:enable line_length
