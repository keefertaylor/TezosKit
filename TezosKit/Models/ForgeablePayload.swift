// Copyright Keefer Taylor, 2019.

import Foundation

public struct ForgeablePayload {
  public var dictionaryRepresentation: [String: Any] {
    return [
      "contents": contents,
      "branch": branch
    ]
  }

  private let contents: [[String: Any]]
  private let branch: String

  public init(contents: [[String: Any]], branch: String) {
    self.contents = contents
    self.branch = branch
  }
}
