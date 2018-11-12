// Copyright Keefer Taylor, 2018

import Foundation

/**
 * A response adapter is an adapter that takes abstract data and turns it into a given type.
 * Adapters can be used to transform arbitrary network bytes from RPCs into concrete model types.
 */
protocol ResponseAdapter {
  /** The type that this ResponseAdapter will parse to. */
  associatedtype ParsedType

  /** Parse the given data to the given type. */
  static func parse(input: Data) -> ParsedType?
}
