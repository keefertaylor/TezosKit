// Copyright Keefer Taylor, 2018

import Foundation

public indirect enum TezosKitError: Error, Equatable {
  case internalError
  case invalidURL
  case localForgingNotSupportedForOperation
  case preapplicationError(description: String)
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
