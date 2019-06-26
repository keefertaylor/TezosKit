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

/// A fake URLSession that will return data tasks which will call completion handlers with the given parameters.
public class FakeURLSession: URLSession {
  public var urlResponse: URLResponse?
  public var data: Data?
  public var error: Error?

  public override func dataTask(
    with request: URLRequest,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
    return FakeURLSessionDataTask(
      urlResponse: urlResponse,
      data: data,
      error: error,
      completionHandler: completionHandler
    )
  }
}

/// A fake data task that will immediately call completion.
public class FakeURLSessionDataTask: URLSessionDataTask {
  private let urlResponse: URLResponse?
  private let data: Data?
  private let fakedError: Error?
  private let completionHandler: (Data?, URLResponse?, Error?) -> Void

  public init(
    urlResponse: URLResponse?,
    data: Data?,
    error: Error?,
    completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
    self.urlResponse = urlResponse
    self.data = data
    self.fakedError = error
    self.completionHandler = completionHandler
  }

  public override func resume() {
    completionHandler(data, urlResponse, fakedError)
  }
}
