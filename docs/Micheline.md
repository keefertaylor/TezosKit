# Smart Contract Invocation

Micheline primitives are provided to allow smart contracts invocation. Use the `TODO: API`

## Micheline Parameters

All available parameters conform to the `MichelineParameter` protocol. Available parameters include:
- Unit (`MichelineUnitParam`)
- Bool
- Int
- String
- Bytes
- Left
- Right
- Pair 
- Some
- None

# Custom Parameters

If a parameter is not supported, the `CustomMichelineParam` struct can be used to create a custom parameter type. Simply pass the swift dictionary representation of the parameter's JSON. For instance, to encode: 

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

Then using TezosKit:

```swift
let annotsArray = [ "@TezosKit" ]
let jsonArgsArray = [ "int" : "32" ]
let jsonDict: [String: Any] = [
  "prim": "left",
  "args": jsonArgsArray,
  "annots": annotsArray
]

let michelineParam = CustomMichelineParam(networkRepresentation: jsonDict)
```

You can find the JSON specicification for Micheline here: https://tezos.gitlab.io/master/whitedoc/michelson.html#json-syntax.

## Annotations

Annotations do not have first class support in TezosKit. Please file an issue if you have a use case that uses annotations.