// Copyright Keefer Taylor, 2018

import TezosKit
//
//  GetAddressManagerKeyRPCTest.swift
//  TezosKitTests
//
//  Created by Keefer Taylor on 10/26/18.
//  Copyright © 2018 Keefer Taylor. All rights reserved.
//
import XCTest

class GetAddressManagerKeyRPCTest: XCTestCase {
  public func testGetAddressManagerKeyRPC() {
    let address = "abc123"
    let rpc = GetAddressManagerKeyRPC(address: address) { _, _ in }

    XCTAssertEqual(rpc.endpoint, "/chains/main/blocks/head/context/contracts/" + address + "/manager_key")
    XCTAssertNil(rpc.payload)
    XCTAssertFalse(rpc.isPOSTRequest)
  }
}
