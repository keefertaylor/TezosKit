// Copyright Keefer Taylor, 2019

import Foundation
import PocketSwift
/// Pocket Network provides a trustless API Layer, allowing easy acccess to the Tezos Network
/// The PocketNetworkClient classs is an implementation of the NetworkClient protocol
/// Adds the necesary information to interact with the Pocket Network
public class PocketNetworkClient: NetworkClient {
    /// Network name
    private let network = "TEZOS"
    /// Network ID
    private let netID: String
    /// Developer ID
    /// NOTE: All Pocket tests require a DeveloperID,
    /// For more information visit: https://docs.pokt.network/docs/how-to-participate
    private let devID: String
    /// Pocket Instance that will relay requests
    private let pocket: Pocket
    /// Headers which will be added to every request.
    private let headers: [Header]
    /// A response handler for RPCs.
    private let responseHandler: RPCResponseHandler
    /// The queue that callbacks from requests will be made on.
    internal let callbackQueue: DispatchQueue
    /// Initialize a new AbstractNetworkClient.
    /// - Parameters:
    ///   - devID: Pocket developer identifier.
    ///   - netID: Tezos network identifier.
    ///   - headers: The path to the remote node.
    ///   - urlSession: The URLSession that will manage network requests.
    ///   - headers: Headers which will be added to every request.
    ///   - callbackQueue: A dispatch queue that callbacks will be made on.
    ///   - responseHandler: An object which will handle responses.
    ///   - maxNodes: (Optional) Max amount of nodes to be stored in the instance .
    ///   - requestTimeOut: (Optional) Maximum timeout for each request.
    public init(
        devID: String,
        netID: String,
        headers: [Header] = [],
        callbackQueue: DispatchQueue,
        responseHandler: RPCResponseHandler,
        maxNodes: Int = 10,
        requestTimeOut: Int = 10000
        ) {
        self.netID = netID
        self.devID = devID
        self.headers = headers
        self.callbackQueue = callbackQueue
        self.responseHandler = responseHandler
        self.pocket = Pocket(devID: devID, network: network, netID: netID, maxNodes: maxNodes, requestTimeOut: requestTimeOut)
    }
    public func send<T>(_ rpc: RPC<T>, callbackQueue: DispatchQueue?, completion: @escaping (Result<T, TezosKitError>) -> Void) {
        
    }
    public func send<T>(_ rpc: RPC<T>, completion: @escaping (Result<T, TezosKitError>) -> Void) {
        var httpMethod = Relay.HttpMethod.GET
        var data = ""
        // Check if rpc is a POST request
        if rpc.isPOSTRequest {
            httpMethod = Relay.HttpMethod.POST
            data = rpc.payload ?? ""
        }
        // Add headers from RPC.
        var headers = [String: String]()
        for header in rpc.headers {
            headers[header.field] = header.value
        }
        
        let relay = Relay(
            network: self.network,
            netID: self.netID,
            data: data,
            devID: self.devID,
            httpMethod: httpMethod,
            path: rpc.endpoint,
            queryParams: nil,
            headers: nil
        )

        pocket.send(
            relay: relay,
            onSuccess: { response in
                let data = response.data(using: .utf8)
                let result = self.responseHandler.handleResponse(
                    response: nil,
                    data: data,
                    error: nil,
                    responseAdapterClass: rpc.responseAdapterClass
                )
                self.callbackQueue.async {
                    completion(result)
                }
            },
            onError: { error in
                let result = self.responseHandler.handleResponse(
                    response: nil,
                    data: nil,
                    error: error,
                    responseAdapterClass: rpc.responseAdapterClass
                )
                self.callbackQueue.async {
                    completion(result)
                }
            }
        )
    }

}
