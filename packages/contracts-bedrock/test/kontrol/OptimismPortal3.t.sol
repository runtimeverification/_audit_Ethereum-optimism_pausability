// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Libraries
import { Types } from "src/libraries/Types.sol";

import { SetupCheatcode } from "test/kontrol/SetupCheatcode.sol";
import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";

contract OptimismPortalTest3 is SetupCheatcode {
    SuperchainConfig superchainConfig;
    OptimismPortal optimismPortal;

    function setUp() public {
        recreateDeployment();
        superchainConfig = SuperchainConfig(payable(SuperchainConfigProxyAddress));
        optimismPortal = OptimismPortal(payable(OptimismPortalProxyAddress));
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
