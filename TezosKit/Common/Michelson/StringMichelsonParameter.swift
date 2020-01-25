// Copyright Keefer Taylor, 2019.

import Foundation

/// A representation of a string parameter in Michelson.
public class StringMichelsonParameter: AbstractMichelsonParameter {
  public init(string: String, annotations: [MichelsonAnnotation]? = nil) {
    super.init(networkRepresentation: [MichelineConstants.string: string], annotations: annotations)
  }

  public convenience init(date: Date, annotations: [MichelsonAnnotation]? = nil) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    dateFormatter.timeZone = TimeZone(abbreviation: "GMT")

    let string = dateFormatter.string(from: date)

    self.init(string: string, annotations: annotations)
  }
}
