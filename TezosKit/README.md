# Code Overview
A brief overview of the various subfolders.

## App 
Contains app-specific code and resources to build TezosKit into an iOS application. 

It will eventually go away and be replaced by tests when TezosKit is ready to be consumed as a static library and/or framework.

## Client
Contains logic and error handling for the gateway to interact with the Tezos network.

## Cryptography
Contains logic related to signing and key generation.

## Models
Contains model objects for use in TezosKit.

## Operation
Contains representations of operations which can be forged / pre-applied / injected on the Tezos blockchain.

## RPC
Contains code to generate RPCs to the Tezos network and decode their responses.

## Utils
Contains utility code utilized across other classes.
