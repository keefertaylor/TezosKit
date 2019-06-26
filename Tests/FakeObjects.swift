// Copyright Keefer Taylor, 2019

import Foundation
import TezosKit

public struct FakePublicKey: TezosKit.PublicKey {
  public let base58CheckRepresentation: String
}

/// A fake forging service delegate which will use the given completion call as the completion call to any remote forge
/// request.
public class FakeForgingServiceDelegate: ForgingServiceDelegate {
  let completion: () -> Result<String, TezosKitError>
  public init(completion: @escaping () -> Result<String, TezosKitError>) {
    self.completion = completion
  }

  public func forgingService(
    _ forgingService: ForgingService,
    requestedRemoteForgeForPayload operationPayload: OperationPayload,
    withMetadata operationMetadata: OperationMetadata,
    completion: @escaping (Result<String, TezosKitError>) -> Void
  ) {
    completion(self.completion())
  }
}

/// A fake signer.
public class FakeSigner: Signer {
  private let signature: [UInt8]
  public let publicKey: PublicKey

  public init(signature: [UInt8], publicKey: PublicKey) {
    self.signature = signature
    self.publicKey = publicKey
  }

  public func sign(_ payload: String) -> [UInt8]? {
    return signature
  }
}
