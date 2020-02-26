// Copyright Keefer Taylor, 2019.

import Foundation

/// Models a swift dictionary as a JSON representation (Micheline) of a Michelson parameter.
///
/// This abstract base class can be used to create Michelson parameters which TezosKit doesn't support.
public class AbstractMichelsonParameter: MichelsonParameter {
  public let networkRepresentation: JSONCodable

  /// - Parameter networkRepresentation: A dictionary representation of the parameter which can be encoded to JSON.
  /// - Parameter annotations: Optional annotations
  public init(networkRepresentation: [String: Any], annotations: [MichelsonAnnotation]? = nil) {
    var annotationAugmentedDictionary = networkRepresentation
    if let annotations = annotations {
      annotationAugmentedDictionary[MichelineConstants.annotations] = annotations.map { $0.value }
    }

    self.networkRepresentation = annotationAugmentedDictionary
  }

  /// - Parameter networkRepresentation: An array representation of the parameter which can be encoded to JSON.
  public init(networkRepresentation: [Any]) {
    self.networkRepresentation = networkRepresentation
  }
}
