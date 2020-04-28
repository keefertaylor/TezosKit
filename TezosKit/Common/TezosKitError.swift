// Copyright Keefer Taylor, 2018

import Foundation

public indirect enum TezosKitError: Error, Equatable {
  case internalError
  case invalidURL
  case localForgingNotSupportedForOperation
  case operationError([OperationResponseInternalResultError])
  case preapplicationError(description: String)
  case rpcError(description: String)
  case signingError
  case transactionFormationFailure(underlyingError: TezosKitError)
  case unexpectedRequestFormat(description: String)
  case unexpectedResponse(description: String)
  case unknown(description: String?)
}
