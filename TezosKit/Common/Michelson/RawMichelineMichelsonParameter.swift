//
//  RawMichelineMichelsonParameter.swift
//  TezosKit
//
//  Created by Simon Mcloughlin on 04/03/2020.
//

import Foundation

/// Allows passing in Raw Micheline as a dictionary to handle any unsupported types or structures
public class RawMichelineMichelsonParameter: AbstractMichelsonParameter {
	public init(micheline: [String: Any]) {
		super.init(networkRepresentation: micheline, annotations: nil)
	}

	public init(micheline: [Any]) {
		super.init(networkRepresentation: micheline)
	}
}
