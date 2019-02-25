// Copyright Keefer Taylor, 2019. 
import Foundation

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
