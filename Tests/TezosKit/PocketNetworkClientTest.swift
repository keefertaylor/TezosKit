// Copyright Keefer Taylor, 2019.

@testable import TezosKit
import XCTest

class PocketNetworkClientTest: XCTestCase {
    public var networkClient: NetworkClient?
    public let fakeURLSession = FakeURLSession()
    public let callbackQueue: DispatchQueue = DispatchQueue(label: "callbackQueue")
    public var pocket_dev_id = ""
    // Setup
    public override func setUp() {
        super.setUp()

        if let path = Bundle(for: type(of: self)).path(forResource: "ci_config", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let dev_id = jsonResult["POCKET_DEV_ID"] as? String {
                    self.pocket_dev_id = dev_id
                }
            } catch {
                print("Failed to retrieve the Pocket DevID with error: \(error)")
                XCTFail()
            }
        }
        // Initialize PocketNetwork Client
        networkClient = PocketNetworkClient(
            devID: self.pocket_dev_id,
            netID: "MAINNET",
            callbackQueue: callbackQueue,
            responseHandler: RPCResponseHandler()
        )
    }
    // test
    public func testRetrieveNetworkVersion() {
        let expectation = XCTestExpectation(description: "Completion is Called")
        // RPC endpoint will resolve to a valid URL.
        let header = Header.contentTypeApplicationJSON
        let rpc = RPC(endpoint: "/network/version", headers: [header], responseAdapterClass: StringResponseAdapter.self, payload: nil)
        
        networkClient?.send(rpc, completion: { (result) in
            switch result {
            case .failure:
                XCTFail()
            case .success:
                expectation.fulfill()
            }
        })

        wait(for: [expectation], timeout: 10)
    }
    public func testCallbackOnCorrectQueueForBadURL() {
        let expectation = XCTestExpectation(description: "Completion is Called")
        // RPC endpoint will not resolve to a valid URL.
        let rpc = RPC(endpoint: "/    /\"test", responseAdapterClass: StringResponseAdapter.self)
        networkClient?.send(rpc) { _ in
            if #available(iOS 10, OSX 10.12, *) {
                dispatchPrecondition(condition: .onQueue(self.callbackQueue))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    public func testCallbackOnCorrectQueue() {
        let expectation = XCTestExpectation(description: "Completion is Called")
        let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
        networkClient?.send(rpc) { _ in
            if #available(iOS 10, OSX 10.12, *) {
                dispatchPrecondition(condition: .onQueue(self.callbackQueue))
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 10)
    }
    public func testBadEndpointCompletesWithURL() {
        let expectation = XCTestExpectation(description: "Completion is Called")
        // RPC endpoint will not resolve to a valid URL.
        let rpc = RPC(endpoint: "/    /\"test", responseAdapterClass: StringResponseAdapter.self)
        networkClient?.send(rpc) { result in
            switch result {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 20)
    }
    public func testBadHTTPResponseCompletesWithError() {
        // Fake URL session has data but has an HTTP error code.
        fakeURLSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://keefertaylor.com")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil
        )
        fakeURLSession.data = "SomeString".data(using: .utf8)
        let expectation = XCTestExpectation(description: "Completion is Called")
        let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
        networkClient?.send(rpc) { result in
            switch result {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 20)
    }
    public func testErrorCompletesWithError() {
        // Valid HTTP response and data, but error is returned.
        fakeURLSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://keefertaylor.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        fakeURLSession.data = "Result".data(using: .utf8)
        fakeURLSession.error = TezosKitError(kind: .unknown, underlyingError: nil)
        // Expectation
        let expectation = XCTestExpectation(description: "Completion is Called")
        let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
        networkClient?.send(rpc) { result in
            switch result {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 20)
    }
    public func testNilDataCompletesWithError() {
        // Valid HTTP response, but returned data is nil.
        fakeURLSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://keefertaylor.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        // Expectation
        let expectation = XCTestExpectation(description: "Completion is Called")
        let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
        networkClient?.send(rpc) { result in
            switch result {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    public func testInocrrectDataCompletesWithError() {
        // Response is a string but RPC attempts to decode to an int.
        fakeURLSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://keefertaylor.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        // Expectation
        let expectation = XCTestExpectation(description: "Completion is Called")
        let rpc = RPC(endpoint: "/test", responseAdapterClass: IntegerResponseAdapter.self)
        networkClient?.send(rpc) { result in
            switch result {
            case .failure:
                expectation.fulfill()
            case .success:
                XCTFail()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
    public func testRequestCompletesWithResultAndNoError() {
        // A valid response with not HTTP error.
        let expectedString = "Expected!"
        fakeURLSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://keefertaylor.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        fakeURLSession.data = expectedString.data(using: .utf8)
        // Expectation
        let expectation = XCTestExpectation(description: "Completion is Called")
        let rpc = RPC(endpoint: "/test", responseAdapterClass: StringResponseAdapter.self)
        networkClient?.send(rpc) { result in
            switch result {
            case .failure:
                XCTFail()
            case .success(let data):
                XCTAssertEqual(data, expectedString)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
}
