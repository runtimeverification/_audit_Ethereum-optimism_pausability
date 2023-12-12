// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Libraries
import { Types } from "src/libraries/Types.sol";

import { SetupCheatcode } from "./SetupCheatcode.sol";
import {
    SuperchainConfigInterface as SuperchainConfig, OptimismPortalInterface as OptimismPortal
} from "./Interface.sol";

contract OptimismPortalTest is SetupCheatcode {
    SuperchainConfig superchainConfig;
    OptimismPortal optimismPortal;

    function setUp() public {
        recreateDeployment();
        superchainConfig = SuperchainConfig(payable(SuperchainConfigProxyAddress));
        optimismPortal = OptimismPortal(payable(OptimismPortalProxyAddress));
    }

    function test_finalize(address _tx1, address _tx2, uint256 _tx0, uint256 _tx3, uint256 _tx4) external {
        bytes memory _tx5 = hex"";

        Types.WithdrawalTransaction memory _tx = Types.WithdrawalTransaction(_tx0, _tx1, _tx2, _tx3, _tx4, _tx5);
        vm.prank(superchainConfig.guardian());
        superchainConfig.pause("identifier");
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.finalizeWithdrawalTransaction(_tx);
    }
}
