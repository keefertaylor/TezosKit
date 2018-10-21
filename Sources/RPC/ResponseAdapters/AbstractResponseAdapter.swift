import Foundation

/**
 * An abstract super class for all response adapters. This class is a shim to allow generics and
 * associated types to play nicely together.
 */
public class AbstractResponseAdapter<T>: ResponseAdapter {
	public class func parse(input: Data) -> T? {
		fatalError("Use a concrete implementation of the response adapter class")
		return nil
	}

	/** Please do not instantiate adapters. Adapters should only be used as static utility classes. */
	private init() { }
}
