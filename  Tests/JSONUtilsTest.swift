// Copyright Keefer Taylor, 2018

import TezosKit
import XCTest

class JSONUtilsTest: XCTestCase {
  public func testJSONForString() {
    let inputs = [
      "A regular string", // Regular string
      "\"A quoted string\"", // String with escape sequences
    ]

    // Parallel sorted array to |inputs|.
    let expectedOutputs = [
      "\"A regular string\"",
      "\"\"A quoted string\"\"",
    ]

    for (i, input) in inputs.enumerated() {
      let result = JSONUtils.jsonString(for: input)
      XCTAssertEqual(result, expectedOutputs[i])
    }
  }

  public func testJSONForDictionary() {
    let inputs: [[String: Any]] = [
      ["key1": "val1", "key2": "val2"], // Normal
      ["key1": "\"quotedVal1\"", "\"quotedKey2\"": "val2"], // Quoted Strings
      ["key1": "val1", "key2": Int(42)], // Values besides strings
    ]

    // Parallel sorted array to |inputs|.
    let expectedOutputs = [
      "{\"key1\":\"val1\",\"key2\":\"val2\"}",
      "{\"\\\"quotedKey2\\\"\":\"val2\",\"key1\":\"\\\"quotedVal1\\\"\"}",
      "{\"key1\":\"val1\",\"key2\":42}",
    ]

    for (i, input) in inputs.enumerated() {
      // Fail if serialization fails.
      guard let result = JSONUtils.jsonString(for: input) else {
        XCTFail()
        return
      }

      XCTAssertEqual(result, expectedOutputs[i])
    }
  }

  public func testJSONForArray() {
    let inputs: [[[String: Any]]] = [
      [["key1": "val1", "key2": "val2"]], // Normal
      [ // Multiple elements
        ["dict1key1": "dict1val1", "dict1key2": "dict1val2"],
        ["dict2key1": "dict2val1", "dict2key2": "dict2val2"],
      ],
      [["key1": "\"quotedVal1\"", "\"quotedKey2\"": "val2"]], // Quoted Strings
      [["key1": "val1", "key2": Int(42)]], // Values besides strings
    ]

    // Parallel sorted array to |inputs|.
    let expectedOutputs = [
      "[{\"key1\":\"val1\",\"key2\":\"val2\"}]",
      "[{\"dict1key1\":\"dict1val1\",\"dict1key2\":\"dict1val2\"},{\"dict2key1\":\"dict2val1\",\"dict2key2\":\"dict2val2\"}]",
      "[{\"\\\"quotedKey2\\\"\":\"val2\",\"key1\":\"\\\"quotedVal1\\\"\"}]",
      "[{\"key1\":\"val1\",\"key2\":42}]",
    ]

    for (i, input) in inputs.enumerated() {
      // Fail if serialization fails.
      guard let result = JSONUtils.jsonString(for: input) else {
        XCTFail()
        return
      }

      XCTAssertEqual(result, expectedOutputs[i])
    }
  }
}
