import Foundation

protocol ResponseAdapter {
  associatedtype ParsedType

  static func parse(input: Data) -> ParsedType?
}

public class StringResponseAdapter : ResponseAdapter {
  public class func parse(input: Data) -> String? {
    return String(data: input, encoding: .ascii)
  }
}

public class JSONResponseAdapter : ResponseAdapter {
  public class func parse(input: Data) -> Dictionary<String, Any>? {
    do {
      let json = try JSONSerialization.jsonObject(with: input)
      guard let typedJSON = json as? Dictionary<String, Any> else {
        return nil
      }
      return typedJSON
    } catch {
      return nil
    }
  }
}
