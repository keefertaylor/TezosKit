// Copyright Keefer Taylor, 2019.

import Foundation

import TezosCrypto
@testable import TezosKit

/// Extensions to classes to provide static objects for testing.

extension String {
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
    fee: Tez(1.0),
    gasLimit: Tez(2.0),
    storageLimit: Tez(3.0)
  )
}

extension TimeInterval {
  public static let expectationTimeout = 0.1
}

extension Wallet {
  public static let testWallet =
    Wallet(mnemonic: "predict corn duty process brisk tomato shrimp virtual horror half rhythm cook")!
}

extension FakeNetworkClient {
  private static let tezosNodeClientEndpointToResponseMap = [
    "/chains/main/blocks/xyz/helpers/forge/operations": JSONUtils.jsonString(for: .testForgeResult)!
  ]

  public static let tezosNodeNetworkClient =
    FakeNetworkClient(endpointToResponseMap: tezosNodeClientEndpointToResponseMap)
}
