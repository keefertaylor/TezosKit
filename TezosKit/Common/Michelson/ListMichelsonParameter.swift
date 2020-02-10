// Copyright Keefer Taylor, 2020.

import Foundation

public class ListMichelsonParameter: AbstractMichelsonParameter {
  public init(args: [MichelsonParameter]) {
    let argArray = args.map { $0.networkRepresentation }
    super.init(networkRepresentation: argArray)
  }
}
