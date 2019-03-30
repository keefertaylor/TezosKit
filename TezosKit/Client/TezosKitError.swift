// Copyright Keefer Taylor, 2018

import Foundation

public struct TezosKitError: Error {
  /// Enumeration representing possible kinds of errors.
  public enum ErrorKind: String {
    case unknown
    case invalidURL
    case rpcError
    case unexpectedResponse
    case unexpectedRequestFormat
    case signingError
    case preapplicationError
  }

  /// The error code which occurred.
  public let kind: ErrorKind

  /// The underlying error returned from a subsystem, if one exists.
  public let underlyingError: String?

  public init(kind: ErrorKind, underlyingError: String? = nil) {
    self.kind = kind
    self.underlyingError = underlyingError
  }
}

extension TezosKitError: LocalizedError {
  public var errorDescription: String? {
    let errorKindDesc = "TezosKitError " + kind.rawValue
    if let underlyingError = self.underlyingError {
      return underlyingError + " (" + errorKindDesc + ")"
    } else {
      return errorKindDesc
    }
  }
}

extension TezosKitError: Equatable {
  public static func == (lhs: TezosKitError, rhs: TezosKitError) -> Bool {
    return lhs.kind == rhs.kind && lhs.underlyingError == rhs.underlyingError
  }
}
