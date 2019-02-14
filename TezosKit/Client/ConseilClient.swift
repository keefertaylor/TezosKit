// Copyright Keefer Taylor, 2019

import Foundation

public class ConseilClient: NetworkClient {
  public override init(
    remoteNodeURL: URL,
    urlSession: URLSession = URLSession.shared,
    callbackQueue: DispatchQueue = DispatchQueue.main
  ) {
    super.init(remoteNodeURL: remoteNodeURL, urlSession: urlSession, callbackQueue: callbackQueue)
  }
}
