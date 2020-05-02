// Copyright Keefer Taylor, 2020.

import Foundation

/// A representation of a date parameter in Michelson.
public class Timestamp: AbstractMichelsonParameter {
  public init(date: Date, annotations: [MichelsonAnnotation]? = nil) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT")

    let string = dateFormatter.string(from: date)

    super.init(networkRepresentation: [MichelineConstants.string: string], annotations: annotations)
  }
}
