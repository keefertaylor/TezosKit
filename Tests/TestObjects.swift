// Copyright Keefer Taylor, 2019.

import Foundation

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
}

extension Int {
  public static let testAddressCounter = 0
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
  )
}

extension SignedProtocolOperationPayload {
  public static let testSignedProtocolOperationPayload = SignedProtocolOperationPayload(
    signedOperationPayload: .testSignedOperationPayload,
    operationMetadata: .testOperationMetadata
  )
}

extension AbstractOperation {
  public static let testOperation = AbstractOperation(source: .testAddress, kind: .reveal)
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
