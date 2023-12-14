    // SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Types } from "src/libraries/Types.sol";

interface OptimismPortalInterface {
    function GUARDIAN() external view returns (address);

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

interface SuperchainConfigInterface {
    function guardian() external view returns (address);

    function paused() external view returns (bool paused_);

    function pause(string memory _identifier) external;

    function unpause() external;
}

interface L1CrossDomainMessengerInterface {
    function relayMessage(
        uint256 _nonce,
        address _sender,
        address _target,
        uint256 _value,
        uint256 _minGasLimit,
        bytes calldata _message
    )
        external
        payable;
}
