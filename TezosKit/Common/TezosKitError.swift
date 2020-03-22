// Copyright Keefer Taylor, 2018

import Foundation

public enum TezosKitError: Error {
  case internalError
  case invalidURL
  case localForgingNotSupportedForOperation
  case preapplicationError
  case rpcError(description: String)
  case signingError
  case transactionFormationFailure(underlyingError: TezosKitError)
  case unexpectedRequestFormat
  case unexpectedResponse
  case unknown(description: String?)
}

extension TezosKitError: LocalizedError {
  public var errorDescription: String? {
    return "TezosKitError "
    // TODO(keefertaylor): Print error description
    // TODO(keefertaylor): Switch and print any raw values here.
//    if let underlyingError = self.underlyingError {
//      return underlyingError + " (" + errorKindDesc + ")"
//    } else {
//      return errorKindDesc
//    }
  }
}

extension TezosKitError: Equatable {
  public static func == (lhs: TezosKitError, rhs: TezosKitError) -> Bool {
    // TODO(keefertaylor): Does this check associated values as well?
    return lhs == rhs
  }
}
