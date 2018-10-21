import Foundation

/**
 * A custom error domain for errors from the TezosClient.
 */
let tezosClientErrorDomain = "com.keefertaylor.TezosClient"

/**
 * A key in the UserInfo dictionary representing the underlying error.
 */
let tezosClientUnderlyingErrorKey = "tezosClientUnderlyingErrorKey"

/**
 * Enumeration representing possible error codes.
 */
public enum TezosClientErrorCode: Int {
  case unknown = 0
  case rpcError = 1
  case unexpectedResponse = 2
  case unexpectedRequestFormat = 3
}
