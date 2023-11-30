// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {OptimismPortal} from "src/L1/OptimismPortal.sol";
import { Types } from "src/libraries/Types.sol";
import { KontrolUtils } from "./KontrolUtils.sol";
import { DeploymentScriptSimplified } from "./OptimismDeployment.sol";

contract OptimismPortalKontrol is KontrolUtils {

    OptimismPortal optimismPortal;

    function setUp() public {
        optimismPortal = new OptimismPortal();
    }

    function test_proveWithdrawalTransaction_paused(
                                /* WithdrawalTransaction args */
								/* uint256 _tx0, */
								address _tx1,
								address _tx2,
								/* uint256 _tx3, */
								/* uint256 _tx4, */
								/* bytes   memory _tx5, */
                                uint256 _l2OutputIndex,
                                /* OutputRootProof args */
                                bytes32 _outputRootProof0,
                                bytes32 _outputRootProof1,
                                bytes32 _outputRootProof2,
                                bytes32 _outputRootProof3
                                /* bytes[] calldata _withdrawalProof */
    ) external {
        uint256 _tx0 = kevm.freshUInt(32);
        uint256 _tx3 = kevm.freshUInt(32);
        uint256 _tx4 = kevm.freshUInt(32);
        bytes memory _tx5 = abi.encode(kevm.freshUInt(32));

        bytes[] memory _withdrawalProof = freshWithdrawalProof();
        /* bytes[] memory _withdrawalProof = new bytes[](1); */
        /* _withdrawalProof[0] = abi.encode(kevm.freshUInt(32)); */

        Types.WithdrawalTransaction memory _tx = createWithdrawalTransaction (
            _tx0,
            _tx1,
            _tx2,
            _tx3,
            _tx4,
            _tx5
            );
        Types.OutputRootProof memory _outputRootProof = Types.OutputRootProof(
            _outputRootProof0,
            _outputRootProof1,
            _outputRootProof2,
            _outputRootProof3
        );

        /* vm.prank(address(uint160(kevm.freshUInt(20)))); */
        vm.expectRevert("OptimismPortal: paused");
        optimismPortal.proveWithdrawalTransaction(
                                                  _tx,
                                                  _l2OutputIndex,
                                                  _outputRootProof,
                                                  _withdrawalProof
        );
    }

    /* function test_bytes(uint256 symbolicArrayLength) external { */
    /*     vm.assume(symbolicArrayLength < type(uint64).max); */
    /*     bytes[] memory symbolicArray = new bytes[](symbolicArrayLength); */

    /*     for (uint256 i = 0; i < symbolicArray.length; ++i) { */
    /*         symbolicArray[i] = abi.encodePacked(kevm.freshUInt(32)); */
    /*     } */
    /* } */

}
