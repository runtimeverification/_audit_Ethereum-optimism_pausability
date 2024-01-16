// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { DeploymentSummary } from "./utils/DeploymentSummary.sol";
import { KontrolUtils } from "./utils/KontrolUtils.sol";
import { Types } from "src/libraries/Types.sol";
import {
    IStandardBridge as StandardBridge,
    ISuperchainConfig as SuperchainConfig
} from "./interfaces/KontrolInterfaces.sol";

contract StandardBridgeKontrol is DeploymentSummary, KontrolUtils {
    StandardBridge standardBridge;
    SuperchainConfig superchainConfig;

    function setUp() public {
        recreateDeployment();
        standardBridge = StandardBridge(payable(L1StandardBridgeProxyAddress));
        superchainConfig = SuperchainConfig(SuperchainConfigProxyAddress);
    }

    /// TODO: Replace symbolic workarounds with the appropiate
    /// types once Kontrol supports symbolic `bytes` and `bytes[]`
    /// Tracking issue: https://github.com/runtimeverification/kontrol/issues/272
    function test_finalizeBridgeERC20_paused(
        address _localToken,
        address _remoteToken,
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _extraData
    )
        public
    {
        /* bytes memory _extraData = freshBigBytes(320); */

        // After deployment, Optimism portal is enabled
        require(standardBridge.paused() == false, "Bridge should not be paused");

        // Pause Standard Bridge
        vm.prank(superchainConfig.guardian());
        superchainConfig.pause("identifier");

        // Bridge is now paused
        require(standardBridge.paused() == true, "Bridge should be paused");
        /* vm.prank(L1CrossDomainMessengerProxyAddress); */
        vm.prank(address(standardBridge.MESSENGER()));
        /* vm.expectRevert("StandardBridge: paused"); */
        standardBridge.finalizeBridgeERC20(_localToken, _remoteToken, _from, _to, _amount, _extraData);
    }
}
