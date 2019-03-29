// Copyright Keefer Taylor, 2019

import Foundation

public typealias ConseilPredicate = [String: Any]
public typealias ConseilOrderBy = [String: Any]

public enum ConseilQuery: String {
  case fields

  case predicates
  public enum Predicates: String {
    case set
    case field
    case operation
    public enum Operation: String {
      case equal = "eq"
    }
    case inverse

    public static func predicateWith(
      field: String,
      set: [String],
      operation: ConseilQuery.Predicates.Operation = .equal,
      inverse: Bool = false
    ) -> ConseilPredicate {
      return [
        ConseilQuery.Predicates.field.rawValue: field,
        ConseilQuery.Predicates.set.rawValue: set,
        ConseilQuery.Predicates.operation.rawValue: operation.rawValue,
        ConseilQuery.Predicates.inverse.rawValue: inverse
      ]
    }
  }

  case orderBy = "orderby"
  public enum OrderBy: String {
    case field
    case direction
    public enum Direction: String {
      case ascending = "asc"
      case descending = "desc"
    }

    public static func orderBy(
      field: String,
      direction: ConseilQuery.OrderBy.Direction = .descending
    ) -> ConseilOrderBy {
      return [
        ConseilQuery.OrderBy.field.rawValue: field,
        ConseilQuery.OrderBy.direction.rawValue: direction.rawValue
      ]
    }
  }

  case limit

  public static func query(
    fields: [String] = [],
    predicates: [ConseilPredicate],
    orderBy: ConseilOrderBy,
    limit: Int
  ) -> [String: Any] {
    return [
      ConseilQuery.fields.rawValue: fields,
      ConseilQuery.predicates.rawValue: predicates,
      ConseilQuery.orderBy.rawValue: orderBy,
      ConseilQuery.limit.rawValue: limit
    ]
  }
}
