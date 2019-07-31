# Working With Smart Contracts and Michelson

TezosKit provides functionality for working with smart contracts.

## Smart Contract Invocation

Michelson primitives are provided to allow invocation of smart contracts. Simply use the API on `TezosNodeClient`:

```swift
public func call(
  contract: Address,
  amount: Tez = Tez.ZeroBalance,
  parameter: MichelsonParameter? = nil,
  source: Address,
  signatureProvider: SignatureProvider,
  operationFees: OperationFees? = nil,
  completion: @escaping (Result<String, TezosKitError>) -> Void)
)
```

An equivalent API is provided in the `PromiseKit` extension.

### Michelson Parameters

Smart contract invocations can take a single Michelson parameter. TezosKit provides primitives of the most common Michelson parameters.

All available parameters conform to the `MichelsonParameter` protocol. Available parameters include:
- Unit (`UnitMichelsonParameter`)
- Bool (`BoolMichelsonParameter`)
- Int (`IntMichelsonParameter`)
- String (`StringMichelsonParameter`)
- Bytes (`BytesMichelsonParameter`)
- Left (`LeftMichelsonParameter`)
- Right (`RightMichelsonParameter`)
- Pair (`PairMichelsonParameter`) 
- Some (`SomeMichelsonParameter`)
- None (`NoneMichlsonParameter`)

For instance, to compose a contract argument of:
```
Right (Left (Pair 5 "2020-06-29T18:00:21Z"))'
```

the equivalent swift code would be:
```swift
let michelsonParameter = MichelsonRight(
  arg: MichelsonLeft(
    arg: MichelsonPair(
      left: MichelsonInt(int: 5),
      right: MichelsonString(string:  "2020-06-29T18:00:21Z")
    )
  )
)
```

### Annotations

Every `MichelsonParameter` can have an optional annotation assigned to it. Annotations must start with their leading symbol (`:`, `@`, or `%`). By default, parameters are not annotated.

### Custom Parameters

If a parameter type is not supported, TezosKit provides an abstract class to allow implementation. Simply instantiate a `AbstractMichelsonParameter`. Since all Michelson parameters are encoded to JSON when interacting over the network, `AbstractMichelsonParameter` simply takes a swift dictionary that will be encoded to JSON. In fact, every other Michelson parameter in TezosKit inherits from this class to implement parameter types.

For instance, to encode the parameter of type:
```javascript
{
  "prim": "left",
  "args": [
    "int": "42",
  ],
  "annots": [
    "@TezosKit"
  ]
}
```

then the following swift code could be used:
```swift
let annotsArray = [ "@TezosKit" ]
let jsonArgsArray = [ "int" : "32" ]
let jsonDict: [String: Any] = [
  "prim": "left",
  "args": jsonArgsArray,
  "annots": annotsArray
]

let michelineParam = AbstractMichelineParam(networkRepresentation: jsonDict)
```

You can find the JSON specicification for Micheline here: https://tezos.gitlab.io/master/whitedoc/michelson.html#json-syntax.

## Contract Introspection

TezosKit can also introsepct contract storage and big maps. Since the set of entities in these fields is a superset of the parameters TezosKit supports, the a raw `Dictionary` (`[String: Any]`) containing the contents of the field is returned. In the future, TezosKit will properly parse and return these fields as first class objects. 

### Introspect Contract Storage
Simply call the contract storage API on TezosNodeClient. The result will be a `[String: Any]` object which represents the JSON structure of the contract's storage.

```swift
let contractAddress = "KT1..."
let tezosNodeClient = TezosNodeClient()
tezosNodeClient.getContractStorage(address: contractAddress) { result in
  ...
}
```

An equivalent `Promises` API is provided in the `PromiseKit` extension.

### Introspect A Big Map
Big maps allow introspection of a single value at a time. The key value must have a value (which is a `MichelsonParameter`) and a type. The `MichelsonComparable` enum defines valid types. The result will be a `[String: Any]` object which represents the JSON structure of the contract's storage.

For instance, to retrieve the value stored in a big map that is keyed by addresses:

```swift
let tezosNodeClient = TezosNodeClient()

// Smart contract containing a big map
let contractAddress = "KT1BVAXZQUc4BGo3WTJ7UML6diVaEbe4bLZA"

// Key for the map.
let key = StringMichelsonParameter(string: "tz1RYq8wjcCbRZykY7XH15WPkzK7TWwPvJJt")

// Type to interpret the key as.
let type: MichelsonComparable = .address

self.nodeClient.getBigMapValue(
  address: contractAddress,
  key: key,
  type: type
) { result in
  ...
}
```

As always, an equivalent `Promises` API is provided in the `PromiseKit` extension.
