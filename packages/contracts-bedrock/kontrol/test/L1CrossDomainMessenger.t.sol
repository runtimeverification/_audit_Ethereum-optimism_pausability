// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Libraries
import { Types } from "src/libraries/Types.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";

import { KontrolUtils } from "kontrol/src/KontrolUtils.sol";
import { DeploymentSummary } from "kontrol/src/DeploymentSummary.sol";

contract L1CrossDomainMessengerTest is DeploymentSummary, KontrolUtils {
    SuperchainConfig superchainConfig;
    L1CrossDomainMessenger l1CrossDomainMessenger;

    function setUp() public {
        recreateDeployment();
        superchainConfig = SuperchainConfig(payable(SuperchainConfigProxyAddress));
        l1CrossDomainMessenger = L1CrossDomainMessenger(payable(L1CrossDomainMessengerProxyAddress));
    }

    function test_relayMessage(
        uint256 _nonce,
        address _sender,
        address _target,
        uint256 _value,
        uint256 _gas
    )
        external
    {
        vm.prank(superchainConfig.guardian());
        superchainConfig.pause("identifier");
        vm.expectRevert("CrossDomainMessenger: paused");

        l1CrossDomainMessenger.relayMessage(_nonce, _sender, _target, _value, _gas, hex"1111");
    }
}
