// Copyright Keefer Taylor, 2019

import Foundation

/// An opaque network client which implements requests.
public protocol NetworkClient {
	/// Send an RPC.
	///
	/// - Note: Callbacks for the RPC will run on the callback queue the network client was initialized with.
	///
	/// - Parameters:
	///   - rpc: The RPC to send.
	///   - completion: A completion block which contains the results of the RPC.
	func send<T>(
		_ rpc: RPC<T>,
		completion: @escaping (Result<T, TezosKitError>) -> Void
	)
	
	/// Send an RPC which runs a callback on a custom queue.
	///
	/// - Note: Callbacks for the RPC will run on the callback queue provided.
	///
	/// - Parameters:
	///   - rpc: The RPC to send.
	///   - callbackQueus: A callback queue to call the completion block on. If nil, the default queue will be used.
	///   - completion: A completion block which contains the results of the RPC.
	func send<T>(
		_ rpc: RPC<T>,
		callbackQueue: DispatchQueue?,
		completion: @escaping (Result<T, TezosKitError>) -> Void
	)
	
	var errorCallback: ((String?, String?, Error, String) -> Void)? { get set }
}

/// A standard implementation of the network client.
public class NetworkClientImpl: NetworkClient {
	
	/// The URL session that will be used to manage URL requests.
	private let urlSession: URLSession
	
	/// A URL pointing to a remote node that will handle requests made by this client.
	private let remoteNodeURL: URL
	
	/// A URL pointing to a remote node that will be used to parse the output of remote forges to ensure the accuracy of the contents
	private let remoteNodeParseURL: URL
	
	/// Headers which will be added to every request.
	private let headers: [Header]
	
	/// A response handler for RPCs.
	private let responseHandler: RPCResponseHandler
	
	/// The queue that callbacks from requests will be made on.
	internal let callbackQueue: DispatchQueue
	
	public var errorCallback: ((String?, String?, Error, String) -> Void)? = nil
	
	/// Initialize a new AbstractNetworkClient.
	/// - Parameters:
	///   - remoteNodeURL: The path to the remote node.
	///   - remoteNodeParseURL: The path to the remote node used to parse the contents of forged operations.
	///   - urlSession: The URLSession that will manage network requests.
	///   - headers: Headers which will be added to every request.
	///   - callbackQueue: A dispatch queue that callbacks will be made on.
	///   - responseHandler: An object which will handle responses.
	public init(
		remoteNodeURL: URL,
		remoteNodeParseURL: URL,
		urlSession: URLSession,
		headers: [Header] = [],
		callbackQueue: DispatchQueue,
		responseHandler: RPCResponseHandler
	) {
		self.remoteNodeURL = remoteNodeURL
		self.remoteNodeParseURL = remoteNodeParseURL
		self.urlSession = urlSession
		self.headers = headers
		self.callbackQueue = callbackQueue
		self.responseHandler = responseHandler
	}
	
	public func send<T>(
		_ rpc: RPC<T>,
		completion: @escaping (Result<T, TezosKitError>) -> Void
	) {
		send(rpc, callbackQueue: nil, completion: completion)
	}
	
	public func send<T>(
		_ rpc: RPC<T>,
		callbackQueue: DispatchQueue? = nil,
		completion: @escaping (Result<T, TezosKitError>) -> Void
	) {
		// Determine the queue to call completion on. Opt for the callback queue provided in the call's parameters, if
		// provided.
		let completionQueue = callbackQueue ?? self.callbackQueue
		
		var remoteNodeEndpoint = remoteNodeURL
		if rpc is ParseOperationRPC {
			remoteNodeEndpoint = remoteNodeParseURL
		}
		
		remoteNodeEndpoint = remoteNodeEndpoint.appendingPathComponent(rpc.endpoint)
		var urlRequest = URLRequest(url: remoteNodeEndpoint)
		
		Logger.shared.log(">>>>>> Request", level: .debug)
		Logger.shared.log("Endpoint: \(remoteNodeEndpoint)", level: .debug)
		
		Logger.shared.log("Headers: ", level: .debug)
		// Add headers from client.
		for header in headers {
			Logger.shared.log("\(header.field): \(header.value)", level: .debug)
			urlRequest.addValue(header.value, forHTTPHeaderField: header.field)
		}
		
		// Add headers from RPC.
		for header in rpc.headers {
			Logger.shared.log("\(header.field): \(header.value)", level: .debug)
			urlRequest.addValue(header.value, forHTTPHeaderField: header.field)
		}
		
		if
			rpc.isPOSTRequest,
			let payload = rpc.payload,
			let payloadData = payload.data(using: .utf8)
		{
			Logger.shared.log("Payload: ", level: .debug)
			Logger.shared.log(payload, level: .debug)
			
			urlRequest.httpMethod = "POST"
			urlRequest.cachePolicy = .reloadIgnoringCacheData
			urlRequest.httpBody = payloadData
		}
		
		Logger.shared.log(">>>>>> End Request", level: .debug)
		
		let request = urlSession.dataTask(with: urlRequest) { [weak self] data, response, error in
			guard let self = self else {
				return
			}
			
			Logger.shared.log("<<<<<< Response", level: .debug)
			Logger.shared.log("Endpoint: \(remoteNodeEndpoint)", level: .debug)
			if
				let data = data,
				let stringifiedData = String(data: data, encoding: .utf8)
			{
				Logger.shared.log(stringifiedData, level: .debug)
			}
			Logger.shared.log("<<<<<< End Response", level: .debug)
			
			let result = self.responseHandler.handleResponse(
				response: response,
				data: data,
				error: error,
				responseAdapterClass: rpc.responseAdapterClass
			)
			
			
			if case .failure(let error) = result, let errorCallback = self.errorCallback {
				errorCallback(rpc.payload, String(data: data ?? Data(), encoding: .utf8), error, remoteNodeEndpoint.absoluteString)
			}
			
			
			completionQueue.async {
				completion(result)
			}
		}
		request.resume()
	}
}

