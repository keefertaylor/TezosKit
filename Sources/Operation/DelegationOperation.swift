// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to set a delegate for an address. */
public class DelegationOperation: AbstractOperation {
  /** The address that will be set as the delegate. */
  public let delegate: String

  public override var dictionaryRepresentation: [String: String] {
    var operation = super.dictionaryRepresentation
    operation["delegate"] = delegate
    return operation
  }

  /**
   * @param source The address that will delegate funds.
   * @param delegate The address to delegate to.
   */
  public init(source: String, to delegate: String) {
    self.delegate = delegate
    super.init(source: source, kind: .delegation)
  }
}
