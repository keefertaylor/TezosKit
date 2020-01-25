// Copyright Keefer Taylor, 2019.

import Foundation
import Sodium

/// Wrapper the sodium library which allows a single instance to be shared.
extension Sodium {
  public static let shared = Sodium()
}
