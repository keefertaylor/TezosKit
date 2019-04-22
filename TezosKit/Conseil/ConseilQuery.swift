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
      case after = "after"
      case before
      case between
      case endsWith
      case equal = "eq"
      case greaterThan = "gt"
      case `in` = "in"
      case isNull = "isnull"
      case lessThan = "lt"
      case like
      case startsWith
    }
    case inverse

    public static func predicateWith(
      field: String,
      operation: ConseilQuery.Predicates.Operation = .equal,
      set: [String] = [],
      inverse: Bool = false
    ) -> ConseilPredicate {
      return [
        ConseilQuery.Predicates.field.rawValue: field,
        ConseilQuery.Predicates.operation.rawValue: operation.rawValue,
        ConseilQuery.Predicates.inverse.rawValue: inverse,
        ConseilQuery.Predicates.set.rawValue: set
      ]
    }
  }

  case aggregation

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
