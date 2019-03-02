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
  public static let testOperationPayload = OperationPayload(contents: [[:]], operationMetadata: .testOperationMetadata)
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
