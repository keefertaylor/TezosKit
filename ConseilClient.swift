/// A client for a Conseil Server.
public class ConseilClient: AbstractClient {
  /// The platfom that this client will query.
  private let platform: ConseilPlatform
  
  /// The network that this client will query.
  private let network: ConseilNetwork

  /// Initialize a new client for a Conseil Service.
  /// - Parameters: 
  ///   - remoteNodeURL: The path to the remote node.
  ///   - platform: The platform to query, defaults to tezos.
  ///   - network: The network to query, defaults to mainnet.
  ///   - urlSession: The URLSession that will manage network requests, defaults to the shared session.
  ///   - callbackQueue: A dispatch queue that callbacks will be made on, defaults to the main queue.  
  public init(
    remoteNodeURL: URL,
    urlSession: URLSession = URLSession.shared,
    callbackQueue: DispatchQueue = DispatchQueue.main,
    platform: ConseilPlatform = .tezos, 
    network: ConseilNetwork = .mainnet
  ) {    
    self.platform = platform
    self.network = network
    super.init(
      remoteNodeURL: remoteNodeURL,
      urlSession: urlSession,
      callbackQueue: callbackQueue,
      responseHandler: RPCResponseHandler()
    )
  }
  
  /// Retrieve transactions from an account.
  public func operations(for account: String, completion: (Result<[[String: Any]]> -> Void)) {
    let rpc = ConseilTransactionQuery(platform: platform, network: network))
    send(rpc, completion)
  }
}

private enum Params {
  public static let fields = "fields"
  public enum Fields {
    public static let amount = "amount"
    public static let destination = "destination"
    public static let fee = "fee"
    public static let kind = "kind"
    public static let source = "source"
    public static let timestamp = "timestamp"
  }
  
  public static let predicates = "predicates"
  public enum Predicate {
    public static let field = "field"
    public static let operation = "operation"
    public static let set = "set"
  }
  
  public static let orderBy = "orderBy"
  public static let limit = "limit"
  
}

private enum Query {
  public static let fields = "fields"
  public static let predicates = "predicates"
  public static let orderBy = "orderBy"
  public static let limit = "limit"
}




private enum Kind {
  public let transaction = "transaction"
}

private enum Operation {
  public let equal = "eq"
}

private enum OrderBy {
  public static let field = "field"
  public static let direction = "direction"
}

public class ConseilTransactionQuery {
  public init(source: String, limit: Int, platform: ConseilPlatform, network: ConseilNetwork) {
    let url = "/v2/data/" + platform.rawValue + "/" + network.rawValue + "/operations"
    
    // TODO: refactor these to be an enum.
    let fields = [ "timestamp", "source", "destination", "amount", "fee"]
    
    let predicateDict = [
      "field": "kind",
      "set": [ "transaction" ],
      "operation": "eq"
    ]
    
    let predicates = []
    let payloadDict = {
      "fields": fields 
      "predicates": predicates
    }
    
    
    // TODO: Refactor to a dictionary.
    let payload = "{\"fields\": [\"timestamp\", \"source\", \"destination\", \"amount\", \"fee\"],\"predicates\": [{\"field\": \"kind\", \"set\": [\"transaction\"], \"operation\": \"eq\"}, {\"field\": \"source\", \"set\": [\"%s\"], \"operation\": \"eq\"}],\"orderBy\": [{\"field\": \"timestamp\", \"direction\": \"desc\"}],\"limit\": 100}"
  }
}

/// TODOs:
/// - Promises Extension
/// - Integration Tests