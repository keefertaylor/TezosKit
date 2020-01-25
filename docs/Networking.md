# Networking and RPCs

Networking and RPCs is an advanced topic which most users of TezosKit will not have to understand or utilize.

## Network Stack

Internally, TezosKit uses a `URLSession` based network stack. The default session is the `shared` session. Users can inject their own session in the initializer of either `TezosNodeClient` or `ConseilClient`.

## Components of Networking

TezosKit's networking and request / response handling is comprised of three major components:
* RPCs: Encapsulate the request to the node, including the endpoint to request, headers to send, and payload data.
* Response Adapters: Encapsulates parsing the data returned from the API to the expected format
* `NetworkClient`: A class which mediates the interaction between `URLSession`, RPC objects and Response Adapters

### `NetworkClient` 

`NetworkClient` is a class which contians the core logic for transcribing `RPC` and `ResponseAdapter` objects into requests made to the network. `NetworkClient` provdes a closure callback style API as well as a [PromiseKit](https://github.com/mxcl/Promisekit) style API.

A `NetworkClient` is instantiated internally in `ConseilClient` and `TezosClient`. `NetworkClients` are immutable and injected into subcomponents of the clients.

### Response Adapters

`URLSession` returns data from the server. Generally, consumers of an API prefer a more structured representation of that data (either as `dictionary` or some other first class object). 

Response Adapter objects parse `Data` to a requested type. The `ResponseAdapter` protocol defines a generic adapter that has an associated type it will parse to. The protocol defines a single method which transforms `Data` to an optional of the associated type. 

Many types of response adapters are provided by default, but users can create their own as well. 

### RPCs

The `RPC` class defines an RPC that will make a request to a node and return a response. An `RPC` is generic in `T`, which is the expected type of a response. 

RPCs are expected to be initialized with the following properties:
* endpoint: The endpoint that the request will be made to on the node.
* headers: Headers that will be sent with the RPC. Note that headers for all RPCs can be set on the Abstract node. Headers set on an RPC will override these headers.
* responseAdapterClass: A `ResponseAdapter` that is generic in the same type of the RPC. This adapter will change the returned data to the requested output.
* payload: A payload to be sent with the request. 

## Building a Custom RPC

It's easy to build a custom RPC.

First, find or create a `ResponseAdapter` object that will coerce `Data` to the preferred output of the RPC. If a custom response adapter is required, users should subclass `AbstractResponseAdapter`. 

Second, subclass `RPC` and initialize the super class with the required functionality.

Lastly, use a generic send method on a client to send the RPC:
```swift
let nodeClient = TezosNodeClient() // You can also use ConseilClient.
let myCustomRPC = MyCustomRPC(...)
nodeClient.send(myCustomRPC) { result in 
  // handle result.
}
````
