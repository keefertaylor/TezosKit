// Copyright Keefer Taylor, 2019

import Foundation

public enum ConseilQuery: String {
  case fields
//  public enum Fields: String {}

  case predicates
//  public enum Predicates: String {}

  case limit

  public static func query(withLimit limit: Int) -> [String: Any] {
    return [
      ConseilQuery.fields: []
      ConseilQuery.limit = limit
    ]
  }
}
