// Copyright Keefer Taylor, 2019.

import Foundation

/// A Michelson annotation.
public class MichelsonAnnotation {
  public let value: String

  /// Initialize a new annotation.
  ///
  /// - Note: Michelson annotations must start with ':', '%', or '@'.
  public init?(annotation: String) {
    guard annotation.starts(with: ":") || annotation.starts(with: "%") || annotation.starts(with: "@") else {
      return nil
    }
    self.value = annotation
  }
}
