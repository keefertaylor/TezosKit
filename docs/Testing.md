# Testing

TezosKit makes use of both unit tests and integration tests to provide confidence in the reliability of the underlying software.

## Unit Tests

Unit tests are used wherever applicable. All unit tests are hermetic and count towards the code coverage metrics. 

### Running Unit Tests

Open `TezosKit.xcodeproj`, select the `TezosKitTests` target from the drop down menu and run the unit tests from the XCTest UI.

## Integration Tests

TezosKit comes bundled with integration tests to ensure that the code works against a live node. These tests are not hermetic. However, they do allow thorough testing of the code in real life scenarios.

As these tests are non-hermetic, you may find that they flake or fail occasionally due to external factors such as:
- Poor connectivity / network conditions
- Adverse network conditions (i.e. A large amount of bakers are offline)
- Adverse network activity (i.e. All blocks are full)

### Running Integration Tests

Running integration tests requires some setup as a custom environment is needed. 

#### Tezos Node Integration Tests

Running Tezos Node integration tests requires having a running Tezos Node. The integration tests assume that the live node will be running on Alphanet.

To get an Alphanet node up and running, follow instructions [here](https://tezos.gitlab.io/alphanet/introduction/howtoget.html).

The integration tests assume that the test account on Alphanet has a sufficient balance (~100 XTZ) to run the tests. The alphanet test account is [tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW](https://alphanet.tzscan.io/tz1XVJ8bZUXs7r5NV8dHvuiBhzECvLRLR3jW). If the test account needs to be topped up, follow instructions to load additional XTZ from the Alphanet fauce [here](https://tezos.gitlab.io/alphanet/introduction/howtouse.html#faucet).

These tests also utilize a token and Dexter Exchange contract, located at:
https://alphanet.tzscan.io/KT1RrfbcDM5eqho4j4u5EbqbaoEFwBsXA434 and https://alphanet.tzscan.io/KT1Md4zkfCvkdqgxAC9tyRYpRUBKmD1owEi2.

(For more information about Dexter, see: https://gitlab.com/camlcase-dev/dexter/blob/master/docs/dexter-cli.md)


The integration tests assume that an alphanet node is running at the default location, `http://127.0.0.1:8732`. If this is not true, you may change `nodeUrl` in `TezosNodeIntegrationTests.swift` to point to the correct location. 

With setup complete, open `TezosKit.xcodeproj`, select the `IntegrationTests` target from the drop down menu and run the `TezosNodeIntegrationTests` tests from the XCTest UI.

#### Conseil Integration Tests

Running Conseil integration tests requires having a running Conseil service. You can find out more about running your own Conseil service [here](https://github.com/Cryptonomic/Conseil/blob/master/doc/use-conseil.md).

The integration tests will need to know the location and API Key for the Conseil service it will connect to. Open `Tests/IntegrationTests/Conseil/ConseilIntegrationTests` and set the appropriate values for `remoteNodeURL` and `apiKey` at the top of the file.

With setup complete, open `TezosKit.xcodeproj`, select the `IntegrationTests` target from the drop down menu and run the `ConseilIntegrationTests` tests from the XCTest UI.
