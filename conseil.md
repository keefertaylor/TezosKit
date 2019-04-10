# Conseil
## Introduction
[Conseil](https://github.com/cryptonomic/conseil) is a query API for the Tezos blockchain by Cryptonomic. TezosKit provides integration with Conseil to build more advanced queries.

Conseil functionality supports both `Result` style completion blocks or a promises API ([via PromiseKit](https://github.com/mxcl/PromiseKit)).
## Getting Started
### Conseil Client
Create a `ConseilClient` that will connect to a remote Conseil service.

```swift
let apiKey = "a_conseil_api_key_"
let remoteNodeURL = URL(string: "https://conseil.instance.address")!
let conseilClient = ConseilClient(remoteNodeURL: remoteNodeURL, apiKey: apiKey, network: .alphanet)
```
### Get Originated Accounts
Simply make a call to get originated accounts. 

`Result` and completion blocks:
```swift
let conseilClent = ...
let address = "tz1iZEKy4LaAjnTmn2RuGDf2iqdAQKnRi8kY"
conseilClient.originatedAccounts(from: address) { result in
  switch result {
    case .success(let originatedAccounts):
      print("Originated Accounts:")
      print(result)
    case .failure(let error):
      print("Error fetching originated accounts: \(error)")
  }
}
```

Or using Promises:
```swift
let conseilClent = ...
let address = "tz1iZEKy4LaAjnTmn2RuGDf2iqdAQKnRi8kY"
conseilClient.originatedAccounts(from: address).done { result in
  print("Originated Accounts:")
  print(result)
} .catch { error in
  print("Error fetching originated accounts: \(error)")
}
```

### Get Transactions for an Accounts
Use the same style as originated accounts, above.

`Result` and completion blocks:
```swift
let conseilClent = ...
let address = "tz1iZEKy4LaAjnTmn2RuGDf2iqdAQKnRi8kY"
conseilClient.transactions(from: address) { result in
  ...
}
```

Or using Promises:
```swift
let conseilClent = ...
let address = "tz1iZEKy4LaAjnTmn2RuGDf2iqdAQKnRi8kY"
conseilClient.transactoins(from: address).done { result in
  ...
} .catch { error in
  print("Error fetching transactions: \(error)")
}
```

## Advanced Usage
Conseil provides advanced functionality that lets users complex queries that TezosKit may not serve out of the box. If you need to write a more advanced custom query, read on.

This documentation deals with specifics to TezosKit. If you want to know what is possible to query with Conseil, please read [the Conseil Query API documentation](https://github.com/Cryptonomic/Conseil/blob/master/doc/Query.md).
### Custom RPC API
`ConseilClient` will dutifully send along any RPC that subclasses `ConseilQueryRPC`. You can subclass this object to create custom queries:
```swift
public class CustomQueryRPC: ConseilQueryRPC {
  public init(...) {
    super.init(...)
  }
}
```

And send queries to the ConseilClient, with either completion callbacks or promises
```swift
let conseilClent = ConseilClient(...)
let customQueryRPC = CustomQueryRPC(...)

// Either send with completion callbacks
conseilClient.send(customQueryRPC) { result in ... }

// Or with promises
conseilClient.send(customQueryRPC).done { result in ... }
```
### Conseil Query Language
Internally, your custom Query will need to build a dictionary that represents a JSON object that will make the query to Conseil. 

TezosKit provides helper classes to build these queries. Specifically, you can use `ConseilQuery` to get access to constants you need and helper funtions. ConseilQuery also provides public typealiases to make working with queries easier.

Here's how you could build a query that gets up to 100 transactions that are sent from addressA to addressB:
```swift
let accountA = "tz1iZEKy4LaAjnTmn2RuGDf2iqdAQKnRi8kY"
let accountB = "tz1NWfe5f11NTExNuHu8BmGgjDWT9bSsdL5R"

/// Three predicates: 
/// (1) kind of transaction is an operation 
/// (2) source account is accountA
/// (3) destination account is accountB
///
/// Note: ConseilPredicate is simply a typealias for [String: Any].
let predicates: [ConseilPredicate] = [
  ConseilQuery.Predicates.predicateWith(field: "kind", set: ["transaction"]),
  ConseilQuery.Predicates.predicateWith(field: "source", set: [accountA])
  ConseilQuery.Predicates.predicateWith(field: "destination", set: [accountB])
]

/// Ordered by timestamp.
/// Note: Like ConseilPredicate, ConseilOrderBy is simply a typealias for [String: Any]
let orderBy = ConseilQuery.OrderBy.orderBy(field: "timestamp")

/// Bind up to a query.
/// Note: As above, ConseilQuery is also just a typealias for [String: Any]
let query = ConseilQuery.query(predicates: predicates, orderBy: orderBy, limit: 100)
```

### API Endpoints
Lastly, Conseil needs to know what entity it is querying. For instance, for originated accounts, the `accounts` entity is queried. For sent transactions, the `operations` entity is queried.

This entity is provided in the initializer of ConseilQueryRPC. Possible values are defined in the ConseilQuery enum.

### Response Parsing
Like all RPCs in TezosKit, responses are parsed using a class that inherits from `AbstractResponseAdapter`. Response adapters will be called by TezosKit to parse the raw data returned from the RPC to the given type. 

For more information, see the [ResponseAdapter API Section of the TezosKit docs](https://github.com/keefertaylor/tezoskit/docs/TezosNode.md).

## Testing
TezosKit provides integration tests for `ConseilClient` to ensure that features are always working. To run the tests yourself, simply configure the `ConseilURL` and `API Key` in `ConseilIntegrationTests.swift` and run the tests.
