// Copyright Keefer Taylor, 2019.

import BigInt
import Foundation

/// A representation of an nat parameter in Michelson.
public class NatMichelsonParameter: AbstractMichelsonParameter {
  /// Initialize a representation of an integer using an `UInt`.
  ///
  /// Note that the michelson int type is unbounded while `UInt` values have bounded precision. Consider  using the `init(bigUInt:annotations:)`
  /// to represent a full range of values.
  public convenience init(int: UInt, annotations: [MichelsonAnnotation]? = nil) {
    self.init(string: String(int), annotations: annotations)
  }

  /// Initialize a representation of an integer using a positive `Decimal`.
  ///
  /// Note that the michelson int type is unbounded while `Decimal` values have bounded precision. Consider  using the `init(bigUInt:annotations:)`
  /// to represent a full range of values.
  public convenience init?(decimal: Decimal, annotations: [MichelsonAnnotation]? = nil) {
    guard decimal > 0 else {
      return nil
    }

    self.init(string: "\(decimal)", annotations: annotations)
  }

  /// Initialize a representation of an nat using an `BigUInt`.
  public convenience init(bigInt: BigUInt, annotations: [MichelsonAnnotation]? = nil) {
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
