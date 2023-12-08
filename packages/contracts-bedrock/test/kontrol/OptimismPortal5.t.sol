// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Libraries
import { Test } from "forge-std/Test.sol";
import { Types } from "src/libraries/Types.sol";

import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";

contract OptimismPortalTest5 is Test {
    SuperchainConfig superchainConfig;
    OptimismPortal optimismPortal;

    function setUp() public {
        superchainConfig = new SuperchainConfig();
        optimismPortal = new OptimismPortal(L2OutputOracle(address(0)), SystemConfig(address(0)));
    }

    function test_finalize(Types.WithdrawalTransaction memory _tx) external {
        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.finalizeWithdrawalTransaction(_tx);
    }
}
