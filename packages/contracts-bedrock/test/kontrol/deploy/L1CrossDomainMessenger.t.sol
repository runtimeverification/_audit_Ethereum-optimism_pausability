// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Libraries
import { Types } from "src/libraries/Types.sol";
import { KontrolUtils } from "../KontrolUtils.sol";
import { DeployCheatcode } from "../DeployCheatcode.sol";
import {
    SuperchainConfigInterface as SuperchainConfig,
    OptimismPortalInterface as OptimismPortal,
    L1CrossDomainMessengerInterface as L1CrossDomainMessenger
} from "./Interface.sol";

contract L1CrossDomainMessengerTest is DeployCheatcode, KontrolUtils {
    SuperchainConfig superchainConfig;
    OptimismPortal optimismPortal;
    L1CrossDomainMessenger l1CrossDomainMessenger;

    function setUp() public {
        recreateDeployment();
        superchainConfig = SuperchainConfig(payable(SuperchainConfigProxyAddress));
        optimismPortal = OptimismPortal(payable(OptimismPortalProxyAddress));
        l1CrossDomainMessenger = L1CrossDomainMessenger(payable(L1CrossDomainMessengerProxyAddress));
    }

    function test_relayMessage(uint _nonce, address _sender, address _target, uint256 _value, uint256 _gas) external {
        vm.prank(superchainConfig.guardian());
        superchainConfig.pause("identifier");
        vm.expectRevert("CrossDomainMessenger: paused");

        l1CrossDomainMessenger.relayMessage(
            _nonce,
            _sender,
            _target,
            _value,
            _gas,
            hex"1111"
        );
    }
}
