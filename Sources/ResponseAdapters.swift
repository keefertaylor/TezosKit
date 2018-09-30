import Foundation

public class ResponseAdapter<ParsedType> {
  public func parse(input: Data) -> ParsedType? {
    return nil;
  }
}

public class StringResponseAdapter : ResponseAdapter<String> {
  public override func parse(input: Data) -> String? {
    return String(data: input, encoding: .ascii)
  }
}

public class JSONResponseAdapter : ResponseAdapter<Dictionary<String, Any>> {
  public override func parse(input: Data) -> Dictionary<String, Any>? {
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
