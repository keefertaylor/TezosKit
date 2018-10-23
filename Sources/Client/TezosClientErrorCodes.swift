import Foundation

/**
 * A struct representing an error that occured in the Tezos Client.
 */
public struct TezosClientError: Error {

  /**
   * Enumeration representing possible kinds of errors.
   */
  public enum ErrorKind {
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
