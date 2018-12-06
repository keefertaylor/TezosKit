// Copyright Keefer Taylor, 2018

import Foundation

/**
 * Parse a given response as code and storage for a contract.
 */
public class ContractCodeResponseAdapter: AbstractResponseAdapter<ContractCode> {
  public override class func parse(input: Data) -> ContractCode? {
    guard let parsedDictionary = JSONDictionaryResponseAdapter.parse(input: input),
      let code = parsedDictionary["code"] as? [[String: Any]],
      let storage = parsedDictionary["storage"] as? [String: Any] else {
      return nil
    }

    let contractCode = ContractCode(code: code, storage: storage)
    return contractCode
  }
}
