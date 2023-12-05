// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Testing utilities
import { Test } from "forge-std/Test.sol";
import { Setup } from "test/setup/Setup.sol";
import { VmSafe } from "forge-std/Vm.sol";
// Libraries
import { Types } from "src/libraries/Types.sol";

import { console2 as console } from "forge-std/console2.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { LibStateDiff } from "scripts/libraries/LibStateDiff.sol";

contract OptimismPortalTest2 is Setup, Test {
    modifier statediff() {
        vm.startStateDiffRecording();
        _;
        VmSafe.AccountAccess[] memory accesses = vm.stopAndReturnStateDiff();
        console.log(
            "Writing %d state diff account accesses to snapshots/state-diff/%s.json", accesses.length, name()
        );
        string memory json = LibStateDiff.encodeAccountAccesses(accesses);
        string memory statediffPath = string.concat(vm.projectRoot(), "/snapshots/state-diff/", name(), ".json");
        vm.writeJson({ json: json, path: statediffPath });
    }

    function name() public pure returns (string memory name_) {
        name_ = "statediff";
    }

    function setUp() public virtual override statediff {
        Setup.setUp();
        vm.fee(1 gwei);
        vm.warp(deploy.cfg().l2OutputOracleStartingTimestamp() + 1);
        vm.roll(deploy.cfg().l2OutputOracleStartingBlockNumber() + 1);
        Setup.L1();
        Setup.L2({ cfg: deploy.cfg() });
    }

    function test_finalize() external {
        address alice = address(128);
        address bob = address(256);
        vm.deal(alice, type(uint64).max);
        vm.deal(bob, type(uint64).max);

        Types.WithdrawalTransaction memory _tx = Types.WithdrawalTransaction({
            nonce: 0,
            sender: alice,
            target: bob,
            value: 100,
            gasLimit: 100_000,
            data: hex""
        });
        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.finalizeWithdrawalTransaction(_tx);
    }
}
