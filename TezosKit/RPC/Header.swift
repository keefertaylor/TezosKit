// Copyright Keefer Taylor, 2019

import Foundation

/// An encapsulation of headers to use in an RPC.
public struct Header {
  public static let contentTypeApplicationJSON = Header(field: "Content-Type", value: "application/json")

  public let field: String
  public let value: String
}
