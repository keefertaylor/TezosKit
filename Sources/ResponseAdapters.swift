import Foundation

protocol ResponseAdapter {
  associatedtype ParsedType

  static func parse(input: Data) -> ParsedType?
}

/** Abstract class allows generics and associated types to play nicely together. */
public class AbstractResponseAdapter<T>: ResponseAdapter {
  public class func parse(input: Data) -> T? {
    fatalError("Use a concrete implementation of the response adapter class")
    return nil
  }
}

public class StringResponseAdapter : AbstractResponseAdapter<String> {
  public override class func parse(input: Data) -> String? {
    return String(data: input, encoding: .ascii)
  }
}

public class TezosBalanceAdapter : AbstractResponseAdapter<TezosBalance> {
  public override class func parse(input: Data) -> TezosBalance? {
    guard let balanceString = StringResponseAdapter.parse(input: input) else {
      return nil
    }
    return TezosBalance(balance: balanceString)
  }
}

public class JSONArrayResponseAdapter : AbstractResponseAdapter<[[String : Any]]> {
  public override class func parse(input: Data) -> [[String : Any]]? {
    do {
      let json = try JSONSerialization.jsonObject(with: input)
      guard let typedJSON = json as? [Dictionary<String, Any>] else {
        return nil
      }
      return typedJSON
    } catch {
      return nil
    }
  }
}

public class JSONDictionaryResponseAdapter : AbstractResponseAdapter<[String : Any]> {
  public override class func parse(input: Data) -> [String : Any]? {
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
