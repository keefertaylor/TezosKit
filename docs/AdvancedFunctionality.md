# Advanced Functionality
TezosKit provides advanced functionality and extensibility out of the box. 

## Custom RPCs and Operations
Users can create their own RPCs and Operations to support operations on the chain which TezosKit does not provide support for. 

See:
* [RPC Documentation](Networking.md)
* [Operation Documentation](Operations.md)

## Preapplication

Every operation in TezosKit is pre-applied before it is injected in the block chain to catch errors.

A future update of TezosKit will make this functionality optional.

## Local Operation Forging
Forging of operations is currently done remotely.

A future update of TezosKit will make this functionality available locally and provide a toggle to change functionality.

## Fees
Users can set custom fees on operations. See the [Fees Documentation](Fees.md). 

A future update of TezosKit will provide gas estimation.