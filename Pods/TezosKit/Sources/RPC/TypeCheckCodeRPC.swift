import Foundation

/** An RPC which will type check code. */
// TODO: Add tests for this class.
public class TypeCheckCodeRPC: TezosRPC<String> {
	/**
   * TODO: Finish.
   * @param completion A block to call when the RPC is complete.
   */
	public init(completion: @escaping (String?, Error?) -> Void) {
		var payload: [String: Any] = [:]
		payload["code"] = ""
		payload["gas"] = "10000"

		let jsonPayload = JSONUtils.jsonString(for: payload)
		let endpoint = "/chains/main/blocks/head/helpers/scripts/typecheck_code"
		super.init(endpoint: endpoint,
			responseAdapterClass: StringResponseAdapter.self,
			payload: jsonPayload,
			completion: completion)
	}
}
