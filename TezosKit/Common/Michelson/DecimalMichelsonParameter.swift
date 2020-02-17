//
//  DecimalMichelsonParameter.swift
//  TezosKit
//
//  Created by Simon Mcloughlin on 17/02/2020.
//

import Foundation

/// A representation of an Decimal parameter in Michelson.
public class DecimalMichelsonParameter: AbstractMichelsonParameter {
  public init(decimal: Decimal, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [MichelineConstants.int: "\(decimal)"], annotations: annotations)
  }
}
