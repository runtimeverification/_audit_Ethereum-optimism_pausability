pragma solidity ^0.8.13;

import { DeploymentSummary } from "./utils/DeploymentSummary.sol";
import { KontrolUtils } from "./utils/KontrolUtils.sol";
import { Types } from "src/libraries/Types.sol";
import {
    OptimismPortalInterface as OptimismPortal,
    SuperchainConfigInterface as SuperchainConfig
} from "./interfaces/KontrolInterfaces.sol";

contract OptimismPortalKontrol is DeploymentSummary, KontrolUtils {
    OptimismPortal optimismPortal;
    SuperchainConfig superchainConfig;

    /* function setUp() public { */
    /*     recreateDeployment(); */
    /*     optimismPortal = OptimismPortal(payable(OptimismPortalProxyAddress)); */
    /*     superchainConfig = SuperchainConfig(SuperchainConfigProxyAddress); */
    /* } */

    function test_kontrol_in_foundry(
        bytes[] memory _withdrawalProof,
        Types.OutputRootProof memory _outputRootProof,
        uint256 _l2OutputIndex,
        Types.WithdrawalTransaction memory _tx
    )
        external
    {
        assert(optimismPortal.paused() == false);

        /* Pause Optimism Portal */
        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");

        /* Portal is now paused */
        assert(optimismPortal.paused() == true);

        /* No one can call proveWithdrawalTransaction */
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.proveWithdrawalTransaction(_tx, _l2OutputIndex, _outputRootProof, _withdrawalProof);
    }

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
        assert(optimismPortal.paused() == false);

        /* Pause Optimism Portal */
        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");

        /* Portal is now paused */
        assert(optimismPortal.paused() == true);

        /* No one can call proveWithdrawalTransaction */
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.proveWithdrawalTransaction(_tx, _l2OutputIndex, _outputRootProof, _withdrawalProof);
    }

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
        assert(optimismPortal.paused() == false);

        /* Pause Optimism Portal */
        vm.prank(optimismPortal.GUARDIAN());
        superchainConfig.pause("identifier");

        /* Portal is now paused */
        assert(optimismPortal.paused() == true);

        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.finalizeWithdrawalTransaction(_tx);
    }

    function test_proveWithdrawalTransaction_calldata(
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

        /* Dummy call to the 0 address */
        vm.expectRevert();
        optimismPortal.proveWithdrawalTransaction(_tx, _l2OutputIndex, _outputRootProof, _withdrawalProof);
    }
}
