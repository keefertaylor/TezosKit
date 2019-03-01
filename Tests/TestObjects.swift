// Copyright Keefer Taylor, 2019.

import Foundation

import TezosCrypto
@testable import TezosKit

/// Extensions to classes to provide static objects for testing.

extension OperationMetadata {
  public static let testOperationMetadata = OperationMetadata(
    chainID: "abc",
    branch: "xyz",
    protocol: "alpha",
    addressCounter: 0,
    key: "123"
  )
}

extension OperationPayload {
  public static let testOperationPayload = OperationPayload(contents: [[:]], operationMetadata: .testOperationMetadata)
}

extension SignedOperationPayload {
  public static let testSignedOperationPayload = SignedOperationPayload(
    operationPayload: .testOperationPayload,
    signature: "abc123"
  )
}

extension SignedProtocolOperationPayload {
  public static let testSignedProtocolOperationPayload = SignedProtocolOperationPayload(
    signedOperationPayload: .testSignedOperationPayload,
    operationMetadata: .testOperationMetadata
  )
}
