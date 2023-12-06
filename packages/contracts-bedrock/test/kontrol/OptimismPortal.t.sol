// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Testing utilities
import { Test } from "forge-std/Test.sol";
import { Setup } from "test/setup/Setup.sol";
import { CommonTest } from "test/setup/CommonTest.sol";
// Libraries
import { Types } from "src/libraries/Types.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
// Target contract dependencies
import { KontrolCheats } from "kontrol-cheatcodes/KontrolCheats.sol";

contract SymbolicBytesGhost {
    bytes public symbolicBytesGhost;
}

contract OptimismPortalTest is CommonTest, KontrolCheats {
    // Use a constructor to set the storage vars above, so as to minimize the number of ffi calls.
    constructor() { }

    /// @dev Setup the system for a ready-to-use state.
    function setUp() public override { }

    /// @dev Creates a fresh bytes with length greater than 31
    /// @param bytesLength: Length of the fresh bytes. Should be concrete
    function freshBigBytes(uint256 bytesLength) internal returns (bytes memory sBytes) {
        require(bytesLength >= 32, "Small bytes");

        uint256 bytesSlotValue;
        unchecked {
            bytesSlotValue = bytesLength * 2 + 1;
        }

        /* Deploy ghost contract */
        SymbolicBytesGhost symbolicBytesGhost = new SymbolicBytesGhost();

        /* Make the storage of the ghost contract symbolic */
        kevm.symbolicStorage(address(symbolicBytesGhost));

        /* Load the size encoding into the first slot of symbolicBytesGhost*/
        vm.store(address(symbolicBytesGhost), bytes32(uint256(0)), bytes32(bytesSlotValue));

        /* vm.assume(symbolicBytesGhost.bytesLength() == bytesLength); */
        sBytes = symbolicBytesGhost.symbolicBytesGhost();
    }

    function freshWithdrawalProof() public returns (bytes[] memory withdrawalProof) {
        /* Assuming arrayLength = 10 for faster proof speeds. For full generality replace with <= */
        uint256 arrayLength = 2;
        /* uint256 arrayLength = kevm.freshUInt(32); */
        /* vm.assume(arrayLength <= 10); */

        withdrawalProof = new bytes[](arrayLength);

        for (uint256 i = 0; i < withdrawalProof.length; ++i) {
            withdrawalProof[i] = freshBigBytes(60); // abi.encodePacked(freshBytes32());  //
                // abi.encodePacked(kevm.freshUInt(32));
        }
    }

    /// @dev Tests that `proveWithdrawalTransaction` reverts when paused.
    function runProve(
        address _tx1,
        address _tx2,
        uint256 _l2OuputIndex,
        bytes32 _version,
        bytes32 _stateRoot,
        bytes32 _storageRoot,
        bytes32 _blockHash
    )
        external
    {
        uint256 _tx0 = kevm.freshUInt(32);
        uint256 _tx3 = kevm.freshUInt(32);
        uint256 _tx4 = kevm.freshUInt(32);
        bytes memory _tx5 = abi.encode(kevm.freshUInt(32));

        bytes[] memory _withdrawalProof = freshWithdrawalProof();

        Types.WithdrawalTransaction memory _tx = Types.WithdrawalTransaction(_tx0, _tx1, _tx2, _tx3, _tx4, _tx5);

        // Setup a dummy output root proof for reuse.
        Types.OutputRootProof memory _outputRootProof = Types.OutputRootProof({
            version: _version,
            stateRoot: _stateRoot,
            messagePasserStorageRoot: _storageRoot,
            latestBlockhash: _blockHash
        });

        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.proveWithdrawalTransaction({
            _tx: _tx,
            _l2OutputIndex: _l2OuputIndex,
            _outputRootProof: _outputRootProof,
            _withdrawalProof: _withdrawalProof
        });
    }

    /// @dev Tests that `finalizeWithdrawalTransaction` reverts if the contract is paused.
    // function test_finalizeWithdrawalTransaction_paused_reverts() external {
    function test_finalize(address _tx1, address _tx2) external {
        uint256 _tx0 = kevm.freshUInt(32);
        uint256 _tx3 = kevm.freshUInt(32);
        uint256 _tx4 = kevm.freshUInt(32);
        bytes memory _tx5 = abi.encode(kevm.freshUInt(32));

        Types.WithdrawalTransaction memory _tx = Types.WithdrawalTransaction(_tx0, _tx1, _tx2, _tx3, _tx4, _tx5);

        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.finalizeWithdrawalTransaction(_tx);
    }
}
