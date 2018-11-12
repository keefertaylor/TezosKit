// Copyright Keefer Taylor, 2018

import Foundation

/**
 * A struct representing an error that occured in the Tezos Client.
 */
public struct TezosClientError: Error {
  /**
   * Enumeration representing possible kinds of errors.
   */
  public enum ErrorKind: String {
    case unknown
    case rpcError
    case unexpectedResponse
    case unexpectedRequestFormat
  }

  /** The error code which occurred. */
  let kind: ErrorKind

  /** The underlying error returned from a subsystem, if one exists. */
  let underlyingError: String?
}

extension TezosClientError: LocalizedError {
  public var errorDescription: String? {
    let errorKindDesc = "TezosClientError " + kind.rawValue
    if let underlyingError = self.underlyingError {
      return underlyingError + " (" + errorKindDesc + ")"
    } else {
      return errorKindDesc
    }
  }
}
