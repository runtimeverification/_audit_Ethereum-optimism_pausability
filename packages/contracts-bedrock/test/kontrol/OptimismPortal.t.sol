 // SPDX-License-Identifier: MIT
 pragma solidity 0.8.15;

 // Testing utilities
 import { stdError, Test } from "forge-std/Test.sol";

 import { CommonTest } from "test/setup/CommonTest.sol";
 import { FFIInterface } from "test/setup/FFIInterface.sol";
 import { NextImpl } from "test/mocks/NextImpl.sol";
 import { EIP1967Helper } from "test/mocks/EIP1967Helper.sol";

 // Libraries
 import { Types } from "src/libraries/Types.sol";
 import { Hashing } from "src/libraries/Hashing.sol";
 import { Constants } from "src/libraries/Constants.sol";

 // Target contract dependencies
 import { Proxy } from "src/universal/Proxy.sol";
 import { ResourceMetering } from "src/L1/ResourceMetering.sol";
 import { AddressAliasHelper } from "src/vendor/AddressAliasHelper.sol";
 import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
 import { SystemConfig } from "src/L1/SystemConfig.sol";
 import { OptimismPortal } from "src/L1/OptimismPortal.sol";

contract OptimismPortalTest is Test {
    // Reusable default values for a test withdrawal
    Types.WithdrawalTransaction _defaultTx;

    uint256 _proposedOutputIndex;
    uint256 _proposedBlockNumber;
    bytes32 _stateRoot;
    bytes32 _storageRoot;
    bytes32 _outputRoot;
    bytes32 _withdrawalHash;
    bytes[] _withdrawalProof;
    Types.OutputRootProof internal _outputRootProof;
    L2OutputOracle l2OutputOracle;
    OptimismPortal optimismPortal;
    FFIInterface ffi;
    // Use a constructor to set the storage vars above, so as to minimize the number of ffi calls.
    constructor() {

        ffi = new FFIInterface();
        address alice = address(128);
        address bob = address(256);
        _defaultTx = Types.WithdrawalTransaction({
             nonce: 0,
             sender: alice,
             target: bob,
             value: 100,
             gasLimit: 100_000,
             data: hex""
        });

        // Get withdrawal proof data we can use for testing.
        (_stateRoot, _storageRoot, _outputRoot, _withdrawalHash, _withdrawalProof) =
            ffi.getProveWithdrawalTransactionInputs(_defaultTx);

        // Setup a dummy output root proof for reuse.
        _outputRootProof = Types.OutputRootProof({
            version: bytes32(uint256(0)),
            stateRoot: _stateRoot,
            messagePasserStorageRoot: _storageRoot,
            latestBlockhash: bytes32(uint256(0))
        });

        // Get the parameters from ./deplpy-config/mainnet.json
        l2OutputOracle = new L2OutputOracle(1800, 2 ,604800);

        _proposedBlockNumber = l2OutputOracle.nextBlockNumber();
        _proposedOutputIndex = l2OutputOracle.nextOutputIndex();

        optimismPortal = new OptimismPortal();
    }

    /// @dev Setup the system for a ready-to-use state.
    function setUp() public {
         // Configure the oracle to return the output root we've prepared.

    }

    /// @dev Tests that `proveWithdrawalTransaction` reverts when paused.
    function run1() external {
        //vm.prank(optimismPortal.GUARDIAN());
        //optimismPortal.pause();

        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.proveWithdrawalTransaction({
             _tx: _defaultTx,
             _l2OutputIndex: _proposedOutputIndex,
             _outputRootProof: _outputRootProof,
             _withdrawalProof: _withdrawalProof
        });
    }

    /// @dev Tests that `finalizeWithdrawalTransaction` reverts if the contract is paused.
    // function test_finalizeWithdrawalTransaction_paused_reverts() external {
    function run2() external {
        // vm.prank(optimismPortal.GUARDIAN());
        // optimismPortal.pause();
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.finalizeWithdrawalTransaction(_defaultTx);
    }

}
