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

    function setUpInlined() public {
        /* recreateDeployment(); */
        standardBridge = StandardBridge(payable(L1StandardBridgeProxyAddress));
        superchainConfig = SuperchainConfig(SuperchainConfigProxyAddress);
    }

    /// TODO: Replace symbolic workarounds with the appropiate
    /// types once Kontrol supports symbolic `bytes` and `bytes[]`
    /// Tracking issue: https://github.com/runtimeverification/kontrol/issues/272
    function prove_finalizeBridgeERC20_paused(
        address _localToken,
        address _remoteToken,
        address _from,
        address _to,
        uint256 _amount
    )
        public
    {
        setUpInlined();
        // bytes32 xDomainMsgSenderDefault = hex"000000000000000000000000000000000000000000000000000000000000dead";
        /* vm.assume(bytes32(uint256(uint160(xDomainMsgSenderValue))) != xDomainMsgSenderDefault); */
        bytes32 slot = hex"00000000000000000000000000000000000000000000000000000000000000cc";
        bytes32 value = bytes32(uint256(uint160(address(standardBridge.OTHER_BRIDGE()))));
        vm.store(L1CrossDomainMessengerProxyAddress, slot, value);
        // vm.store(L1CrossDomainMessengerProxyAddress, hex"00000000000000000000000000000000000000000000000000000000000000cc", bytes32(uint256(uint160(address(standardBridge.OTHER_BRIDGE())))));
        bytes memory _extraData = freshBigBytes(320);

        // After deployment, Optimism portal is enabled
        // require(standardBridge.paused() == false, "Bridge should not be paused");

        // Pause Standard Bridge
        vm.prank(superchainConfig.guardian());
        superchainConfig.pause("identifier");

        // Bridge is now paused
        // require(standardBridge.paused(), "Bridge should be paused");
        /* vm.startPrank(L1CrossDomainMessengerProxyAddress); */
        vm.startPrank(address(standardBridge.MESSENGER()));
        vm.expectRevert("StandardBridge: paused");
        standardBridge.finalizeBridgeERC20(_localToken, _remoteToken, _from, _to, _amount, _extraData);
        vm.stopPrank();
    }

        /// TODO: Replace symbolic workarounds with the appropiate
    /// types once Kontrol supports symbolic `bytes` and `bytes[]`
    /// Tracking issue: https://github.com/runtimeverification/kontrol/issues/272
    function prove_finalizeBridgeETH_paused(
                                              address _from,
                                              address _to,
                                              uint256 _amount
    )
        public
    {
        setUpInlined();
        bytes32 slot = hex"00000000000000000000000000000000000000000000000000000000000000cc";
        bytes32 value = bytes32(uint256(uint160(address(standardBridge.OTHER_BRIDGE()))));
        vm.store(L1CrossDomainMessengerProxyAddress, slot, value);
        // vm.store(L1CrossDomainMessengerProxyAddress, hex"00000000000000000000000000000000000000000000000000000000000000cc", bytes32(uint256(uint160(address(standardBridge.OTHER_BRIDGE())))));
        bytes memory _extraData = freshBigBytes(320);

        // After deployment, Optimism portal is enabled
        // require(standardBridge.paused() == false, "Bridge should not be paused");

        // Pause Standard Bridge
        vm.prank(superchainConfig.guardian());
        superchainConfig.pause("identifier");

        // Bridge is now paused
        // require(standardBridge.paused(), "Bridge should be paused");
        /* vm.startPrank(L1CrossDomainMessengerProxyAddress); */
        vm.startPrank(address(standardBridge.MESSENGER()));
        vm.expectRevert("StandardBridge: paused");
        standardBridge.finalizeBridgeETH(_from, _to, _amount, _extraData);
        vm.stopPrank();
    }
}
