pragma solidity ^0.8.13;

import { DeploymentSummary } from "./utils/DeploymentSummary.sol";
import { KontrolUtils } from "./utils/KontrolUtils.sol";
import { Types } from "src/libraries/Types.sol";
import {
    IOptimismPortal as OptimismPortal,
    ISuperchainConfig as SuperchainConfig,
    IL1CrossDomainMessenger as L1CrossDomainMessenger
} from "./interfaces/KontrolInterfaces.sol";

contract OptimismPortalKontrol is DeploymentSummary, KontrolUtils {
    OptimismPortal optimismPortal;
    SuperchainConfig superchainConfig;
    L1CrossDomainMessenger l1CrossDomainMessenger;

    function setUp() public {
        recreateDeployment();
        optimismPortal = OptimismPortal(payable(OptimismPortalProxyAddress));
        superchainConfig = SuperchainConfig(SuperchainConfigProxyAddress);
        l1CrossDomainMessenger = L1CrossDomainMessenger(L1CrossDomainMessengerProxyAddress);
    }

    /// TODO: Replace struct parameters and workarounds with the appropiate
    /// types once Kontrol supports symbolic `bytes` and `bytes[]`
    function test_proveWithdrawalTransaction_paused(
        /* WithdrawalTransaction args */
        uint256 _tx0,
        address _tx1,
        address _tx2,
        uint256 _tx3,
        uint256 _tx4,
        /* bytes   memory _tx5, */
        uint256 _l2OutputIndex,
        /* OutputRootProof args */
        bytes32 _outputRootProof0,
        bytes32 _outputRootProof1,
        bytes32 _outputRootProof2,
        bytes32 _outputRootProof3
    )
        /* bytes[] calldata _withdrawalProof */
        external
    {
        bytes memory _tx5 = freshBigBytes(320);

        bytes[] memory _withdrawalProof = freshWithdrawalProof();

        Types.WithdrawalTransaction memory _tx = createWithdrawalTransaction(_tx0, _tx1, _tx2, _tx3, _tx4, _tx5);
        Types.OutputRootProof memory _outputRootProof =
            Types.OutputRootProof(_outputRootProof0, _outputRootProof1, _outputRootProof2, _outputRootProof3);

        /* After deployment, Optimism portal is enabled */
        require(optimismPortal.paused() == false, "Portal should not be paused");

        /* Pause Optimism Portal */
        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");

        /* Portal is now paused */
        require(optimismPortal.paused() == true, "Portal should be paused");

        /* No one can call proveWithdrawalTransaction */
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.proveWithdrawalTransaction(_tx, _l2OutputIndex, _outputRootProof, _withdrawalProof);
    }

    /// TODO: Replace struct parameters and workarounds with the appropiate
    /// types once Kontrol supports symbolic `bytes` and `bytes[]`
    function test_finalizeWithdrawalTransaction_paused(
        address _tx1,
        address _tx2,
        uint256 _tx0,
        uint256 _tx3,
        uint256 _tx4
    )
        external
    {
        bytes memory _tx5 = freshBigBytes(320);

        Types.WithdrawalTransaction memory _tx = Types.WithdrawalTransaction(_tx0, _tx1, _tx2, _tx3, _tx4, _tx5);

        /* After deployment, Optimism portal is enabled */
        require(optimismPortal.paused() == false, "Portal should not be paused");

        /* Pause Optimism Portal */
        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");

        /* Portal is now paused */
        require(optimismPortal.paused() == true, "Portal should be paused");

        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.finalizeWithdrawalTransaction(_tx);
    }

    /// TODO: Replace struct parameters and workarounds with the appropiate
    /// types once Kontrol supports symbolic `bytes` and `bytes[]`
    function test_relayMessage_paused(
        uint256 _nonce,
        address _sender,
        address _target,
        uint256 _value,
        uint256 _gas /* , */ /* bytes calldata _message */
    )
        external
    {
        bytes memory _message = freshBigBytes(600);

        /* After deployment, L1CrossDomainMessenger is enabled */
        require(l1CrossDomainMessenger.paused() == false, "L1CrossDomainMessenger should not be paused");

        /* Pause System */
        vm.prank(superchainConfig.guardian());
        superchainConfig.pause("identifier");

        /* L1CrossDomainMessenger is now paused */
        require(l1CrossDomainMessenger.paused() == true, "L1CrossDomainMessenger should be paused");

        vm.expectRevert("CrossDomainMessenger: paused");
        l1CrossDomainMessenger.relayMessage(_nonce, _sender, _target, _value, _gas, _message);
    }
}
