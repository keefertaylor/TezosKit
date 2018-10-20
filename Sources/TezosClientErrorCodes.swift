import Foundation

let tezosClientErrorDomain = "com.keefertaylor.TezosClient"

let tezosClientUnderlyingErrorKey = "tezosClientUnderlyingErrorKey"

public enum TezosClientErrorCode: Int {
  case unknown = 0
  case rpcError = 1
  case unexpectedResponse = 2
  case unexpectedRequestFormat = 3
}
