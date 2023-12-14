// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Libraries
import { Types } from "src/libraries/Types.sol";

import { DeployCheatcode } from "test/kontrol/DeployCheatcode.sol";
import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";
import { OptimismPortal } from "src/L1/OptimismPortal.sol";
import { L2OutputOracle } from "src/L1/L2OutputOracle.sol";
import { L1CrossDomainMessenger } from "src/L1/L1CrossDomainMessenger.sol";
import { Encoding } from "src/libraries/Encoding.sol";

contract OptimismDeployCheatcodeTest is DeployCheatcode {
    SuperchainConfig superchainConfig;
    OptimismPortal optimismPortal;
    L1CrossDomainMessenger l1CrossDomainMessenger;

    function setUp() public {
        recreateDeployment();
        superchainConfig = SuperchainConfig(payable(SuperchainConfigProxyAddress));
        optimismPortal = OptimismPortal(payable(OptimismPortalProxyAddress));
        l1CrossDomainMessenger = L1CrossDomainMessenger(payable(L1CrossDomainMessengerProxyAddress));
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

    function test_prove(
        address alice,
        address bob,
        uint256 nonce,
        uint256 gas,
        uint256 value,
        bytes calldata userData,
        uint256 _l2OutputIndex,
        bytes32 _outputRootProof0,
        bytes32 _outputRootProof1,
        bytes32 _outputRootProof2,
        bytes32 _outputRootProof3
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

        bytes[] memory _withdrawalProof;

        Types.OutputRootProof memory _outputRootProof =
            Types.OutputRootProof(_outputRootProof0, _outputRootProof1, _outputRootProof2, _outputRootProof3);

        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.proveWithdrawalTransaction(_tx, _l2OutputIndex, _outputRootProof, _withdrawalProof);
    }

    function test_relayMessage() external {
        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");
        vm.expectRevert("CrossDomainMessenger: paused");

        l1CrossDomainMessenger.relayMessage(
            Encoding.encodeVersionedNonce({ _nonce: 0, _version: 1 }), // nonce
            address(0),
            address(0),
            0, // value
            0,
            hex"1111"
        );
    }

    function test_concrete() external {
        require(superchainConfig.paused() == false);
        require(superchainConfig.guardian() != address(0));
        vm.prank(superchainConfig.guardian());
        superchainConfig.pause("Guardian Paused");
        require(superchainConfig.paused() == true);
        vm.expectRevert();
        superchainConfig.pause("Some other paused");
    }
}
