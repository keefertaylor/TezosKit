// Copyright Keefer Taylor, 2018

import Foundation

/** A property bag representing various artifacts from signing an operation. */
public struct OperationSigningResult {
  /** The hashed operation bytes which were produced via hashing and signed. */
  public let operationBytes: [UInt8]

  /** The signature of the signed bytes. */
  public let signature: [UInt8]

  /** The base58check encoded version of the signature, prefixed with 'edsig' */
  public let edsig: String

  /** The operation string concatenated with a hex encoded signature. */
  public let sbytes: String
}
