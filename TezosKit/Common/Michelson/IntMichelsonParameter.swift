// Copyright Keefer Taylor, 2019.

import BigInt
import Foundation

/// A representation of an integer parameter in Michelson.
public class IntMichelsonParameter: AbstractMichelsonParameter {
  /// Initialize a representation of an integer using an `Int`.
  ///
  /// Note that the michelson int type is unbounded while `Int` values have bounded precision. Consider  using the `init(bigInt:annotations:)`
  /// to represent a full range of values.
  public convenience init(int: Int, annotations: [MichelsonAnnotation]? = nil) {
    self.init(string: String(int), annotations: annotations)
  }

  /// Initialize a representation of an integer using a `Decimal`.
  ///
  /// Note that the michelson int type is unbounded while `Decimal` values have bounded precision. Consider  using the `init(bigInt:annotations:)`
  /// to represent a full range of values.
  public convenience init(decimal: Decimal, annotations: [MichelsonAnnotation]? = nil) {
    self.init(string: "\(decimal)", annotations: annotations)
  }

  /// Initialize a representation of an integer using an `BigInt`.
  public convenience init(bigInt: BigInt, annotations: [MichelsonAnnotation]? = nil) {
    self.init(string: String(bigInt), annotations: annotations)
  }

  /// Internal initializer.
  ///
  /// - Parameters:
  ///   - string: A numerical string representing the precision.
  ///   - annotations: An array of annotations to apply to the parameter. Defaults to no annotations.
  private init(string: String, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [MichelineConstants.int: string], annotations: annotations)
  }
}
