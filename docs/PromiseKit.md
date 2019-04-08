# PromiseKit

The core of TezosKit provides closure style callbacks.

An extension of the library provides [PromiseKit]() functionality. In CocoaPods, PromiseKit is split into a separate module. In Carthage, all code is delivered as a single module.

### Using Promises

In general, any call you can make on a `TezosNodeClient` or `ConseilClient` can also be done with promises.

For instance, the following closure style callbacks:

```swift
```

Are equivalent to:

```swift
```

### Generic Calls

Both `TezosNodeClient` and `ConseilClient` provide 

*** TODO *** Type Conseil client to ConseilRPC
*** TODO *** Type TNClient to use a TezosNodeRPC
*** TODO *** Make `send` RPC internal

*** TODO *** Write this section.

