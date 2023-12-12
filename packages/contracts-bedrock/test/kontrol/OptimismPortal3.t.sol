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

    // function test_finalize(Types.WithdrawalTransaction memory _tx) external{
    function test_finalize(
        address alice,
        address bob,
        uint256 nonce,
        uint256 gas,
        uint256 value,
        bytes calldata userData
    )
        external
    {
        Types.WithdrawalTransaction memory _tx = Types.WithdrawalTransaction({
            nonce: nonce,
            sender: alice,
            target: bob,
            value: value,
            gasLimit: gas,
            data: userData
        });
        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.finalizeWithdrawalTransaction(_tx);
    }

    function test_concrete() external {
        require(superchainConfig.paused() == false);
        require(superchainConfig.guardian() == GuardianAddress);
        vm.prank(GuardianAddress);
        superchainConfig.pause("Guardian Paused");
        require(superchainConfig.paused() == true);
        vm.expectRevert();
        superchainConfig.pause("Some other paused");
    }
}
