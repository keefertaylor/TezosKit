// Copyright Keefer Taylor, 2019

import Foundation
import TezosCrypto
import TezosKit

public struct FakePublicKey: TezosKit.PublicKey {
  public let base58CheckRepresentation: String
}

public struct FakeSecretKey: TezosKit.SecretKey {
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
  let signature: [UInt8]

  public init(signature: [UInt8]) {
    self.signature = signature
  }

  public func sign(_ payload: String) -> SigningResult? {
    return SigningResult(bytes: signature, hashedBytes: signature, signature: signature)
  }
}
