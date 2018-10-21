import Foundation

/**
 * A RPC which will retrieve the counter for an address.
 */
// TODO: This should really be an integer.
public class GetAddressCounterRPC: TezosRPC<String> {

	/**
   * @param address The address to retrieve info about.
   * @param completion A block to be called at completion of the operation.
   */
	public init(address: String, completion: @escaping (String?, Error?) -> Void) {
		let endpoint = "/chains/main/blocks/head/context/contracts/" + address + "/counter"
		super.init(endpoint: endpoint,
			responseAdapterClass: StringResponseAdapter.self,
			completion: completion)
	}
}
