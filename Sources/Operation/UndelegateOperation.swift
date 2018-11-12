// Copyright Keefer Taylor, 2018

import Foundation

/** An operation to set a clear a delegate for an address. */
public class UndelegateOperation: AbstractOperation {
  /**
   * @param source The address that will delegate funds.
   */
  public init(source: String) {
    super.init(source: source, kind: .delegation)
  }
}
