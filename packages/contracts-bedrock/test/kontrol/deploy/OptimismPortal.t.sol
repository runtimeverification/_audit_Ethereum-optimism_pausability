// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

// Libraries
import { Types } from "src/libraries/Types.sol";
import { KontrolUtils } from "../KontrolUtils.sol";
import { DeployCheatcode } from "../DeployCheatcode.sol";
import {
    SuperchainConfigInterface as SuperchainConfig, OptimismPortalInterface as OptimismPortal
} from "./Interface.sol";

contract OptimismPortalTest is DeployCheatcode, KontrolUtils {
    SuperchainConfig superchainConfig;
    OptimismPortal optimismPortal;

    function setUp() public {
        recreateDeployment();
        superchainConfig = SuperchainConfig(payable(SuperchainConfigProxyAddress));
        optimismPortal = OptimismPortal(payable(OptimismPortalProxyAddress));
    }

    function test_prove(
        address _tx1,
        address _tx2,
        uint256 _l2OutputIndex,
        /* OutputRootProof args */
        bytes32 _outputRootProof0,
        bytes32 _outputRootProof1,
        bytes32 _outputRootProof2,
        bytes32 _outputRootProof3
    )
        external
    {
        uint256 _tx0 = kevm.freshUInt(32);
        uint256 _tx3 = kevm.freshUInt(32);
        uint256 _tx4 = kevm.freshUInt(32);
        bytes memory _tx5 = abi.encode(kevm.freshUInt(32));

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
        /* vm.prank(address(uint160(kevm.freshUInt(20)))); */
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.proveWithdrawalTransaction(_tx, _l2OutputIndex, _outputRootProof, _withdrawalProof);
    }

    function test_finalize(address _tx1, address _tx2, uint256 _tx0, uint256 _tx3, uint256 _tx4) external {
        bytes memory _tx5 = hex"";

        Types.WithdrawalTransaction memory _tx = Types.WithdrawalTransaction(_tx0, _tx1, _tx2, _tx3, _tx4, _tx5);
        vm.prank(superchainConfig.guardian());
        superchainConfig.pause("identifier");
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.finalizeWithdrawalTransaction(_tx);
    }
}
