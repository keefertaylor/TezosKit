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

Annotations do not have first class support in TezosKit. Please file an issue if you have a use case that uses annotations.

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

## Inspecting Smart Contracts

Coming Soon!
