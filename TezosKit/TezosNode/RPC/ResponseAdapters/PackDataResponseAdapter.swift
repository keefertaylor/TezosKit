// Copyright Keefer Taylor, 2020

import Base58Swift
import Foundation
import Sodium

/// Parse a give response to a Base58check encoded set of packed data.
public class PackDataResponseAdapter: AbstractResponseAdapter<String> {
  public override class func parse(input: Data) -> String? {
    guard
      let dictionary = JSONDictionaryResponseAdapter.parse(input: input),
      let packedHex = dictionary["packed"] as? String,
      let packedBinary = CryptoUtils.hexToBin(packedHex)
    else {
      return nil
    }

    // Prefix and Base58Check encode.
    // TODO(keefertaylor): Push this down into the crypto library.
    let hashed = Sodium.shared.genericHash.hash(message: packedBinary, outputLength: 32)!
    let prefix: [UInt8] = [13, 44, 64, 27] // expr
    let prefixedPackedBinary = prefix + hashed

    return Base58.base58CheckEncode(prefixedPackedBinary)
  }
}
