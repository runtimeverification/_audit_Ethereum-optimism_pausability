// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Libraries
import { Types } from "src/libraries/Types.sol";

import { SetupCheatcode } from "test/kontrol/SetupCheatcode.sol";
import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";

import { KontrolCheats } from "kontrol-cheatcodes/KontrolCheats.sol";

contract OptimismPortalTest4 is SetupCheatcode, KontrolCheats {
    SuperchainConfig superchainConfig;
    OptimismPortal optimismPortal;

    function setUp() public {
        recreateDeployment();
        superchainConfig = SuperchainConfig(payable(SuperchainConfigProxyAddress));
        optimismPortal = OptimismPortal(payable(OptimismPortalProxyAddress));
    }

    function test_finalize(address _tx1, address _tx2) external {
        // uint256 _tx0 = kevm.freshUInt(32);
        // uint256 _tx3 = kevm.freshUInt(32);
        // uint256 _tx4 = kevm.freshUInt(32);
        // bytes memory _tx5 = abi.encode(kevm.freshUInt(32));

        // Types.WithdrawalTransaction memory _tx = Types.WithdrawalTransaction(_tx0, _tx1, _tx2, _tx3, _tx4, _tx5);
        // vm.prank(optimismPortal.GUARDIAN());
        // superchainConfig.pause("identifier");
        // vm.expectRevert("OptimismPortal: paused");
        // optimismPortal.finalizeWithdrawalTransaction(_tx);
    }
}
