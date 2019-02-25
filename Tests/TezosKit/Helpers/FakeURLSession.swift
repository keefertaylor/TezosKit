// Copyright Keefer Taylor, 2019.

import Foundation

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
