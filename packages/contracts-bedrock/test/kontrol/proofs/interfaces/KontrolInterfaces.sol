// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Types } from "src/libraries/Types.sol";

interface IOptimismPortal {
    function GUARDIAN() external view returns (address);

    function guardian() external view returns (address);

    function paused() external view returns (bool paused_);

    function proveWithdrawalTransaction(
        Types.WithdrawalTransaction memory _tx,
        uint256 _l2OutputIndex,
        Types.OutputRootProof calldata _outputRootProof,
        bytes[] calldata _withdrawalProof
    )
        external;

    function finalizeWithdrawalTransaction(Types.WithdrawalTransaction memory _tx) external;
}

interface ISuperchainConfig {
    function guardian() external view returns (address);

    function paused() external view returns (bool paused_);

    function pause(string memory _identifier) external;

    function unpause() external;
}

interface ICrossDomainMessenger {
    function xDomainMessageSender() external view returns (address);
}

interface IStandardBridge {
    function paused() external view returns (bool);

    function MESSENGER() external view returns (ICrossDomainMessenger);

    function OTHER_BRIDGE() external view returns (IStandardBridge);

    function finalizeBridgeERC20(
        address _localToken,
        address _remoteToken,
        address _from,
        address _to,
        uint256 _amount,
        bytes calldata _extraData
    )
        external;

    function finalizeBridgeETH(address _from, address _to, uint256 _amount, bytes calldata _extraData) external;
}
