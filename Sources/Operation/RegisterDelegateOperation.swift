// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to set a register and address as a delegate. */
public class RegisterDelegateOperation: AbstractOperation {
  /** The address that will be set as the delegate. */
  public let delegate: String

  public override var dictionaryRepresentation: [String: String] {
    var operation = super.dictionaryRepresentation
    operation["delegate"] = delegate
    return operation
  }

  /**
   * @param delegate The address will register as a delegate.
   */
  public init(delegate: String) {
    self.delegate = delegate
    super.init(source: delegate, kind: .delegation)
  }
}
