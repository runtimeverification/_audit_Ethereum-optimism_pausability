// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Test} from "forge-std/Test.sol";
import {OptimismPortal} from "src/L1/OptimismPortal.sol";
import { Types } from "src/libraries/Types.sol";
import {KontrolCheats} from "kontrol-cheatcodes/KontrolCheats.sol";

contract SymbolicBytes {
    bytes public symbolicBytes;

    function bytesLength() view public returns (uint256) {
        return symbolicBytes.length;
    }
}

contract OptimismPortalKontrol is Test, KontrolCheats {

    OptimismPortal optimismPortal;
    /* SymbolicBytes symbolicBytes; */

    function setUp() public {
        optimismPortal = new OptimismPortal();
        /* symbolicBytes = new SymbolicBytes(); */
    }

    function createWithdrawalTransaction(
      uint256 _tx0,
      address _tx1,
      address _tx2,
      uint256 _tx3,
      uint256 _tx4,
      bytes   memory _tx5
    ) internal pure returns (Types.WithdrawalTransaction memory _tx) {
        _tx = Types.WithdrawalTransaction (
                                           _tx0,
                                           _tx1,
                                           _tx2,
                                           _tx3,
                                           _tx4,
                                           _tx5
        );
    }

    function freshBytesArray(uint256 symbolicArrayLength) public returns (bytes[] memory symbolicArray) {
        symbolicArray = new bytes[](symbolicArrayLength);

        for (uint256 i = 0; i < symbolicArray.length; ++i) {
            symbolicArray[i] = abi.encodePacked(kevm.freshUInt(32));
        }
    }

    /// @dev Returns a symbolic bytes32
    function freshBytes32() public returns (bytes32) {
        return bytes32(kevm.freshUInt(32));
    }

    /// @dev Returns a symbolic adress
    function freshAdress() public returns (address) {
        return address(uint160(kevm.freshUInt(20)));
    }

    function freshBytes(uint256 bytesLength) internal returns (bytes memory sBytes) {
        SymbolicBytes symbolicBytes = new SymbolicBytes();
        vm.assume(symbolicBytes.bytesLength() == bytesLength);
        kevm.symbolicStorage(address(symbolicBytes));
        sBytes = symbolicBytes.symbolicBytes();
        /* for (uint256 i = 0; i < bytesLength; i++) { */
        /*     symbolicBytes = abi.encodePacked(freshBytes32(), symbolicBytes); */
        /* } */
        /* require(symbolicBytes.length == 32 * bytesLength, "freshBytes unsuccesful"); */
    }

    /// @dev Creates a bounded symbolic bytes[] memory representing a withdrawal proof
    /// Each element is 17 * 32 = 544 bytes long, plus ~10% margin for RLP encoding: each element is 600 bytes
    /// The length of the array to 10 or fewer elements
    function freshWithdrawalProof() public returns (bytes[] memory withdrawalProof) {
        /* Assuming arrayLength = 10 for faster proof speeds. For full generality replace with <= */
        uint256 arrayLength = 10;
        /* uint256 arrayLength = kevm.freshUInt(32); */
        /* vm.assume(arrayLength <= 10); */

        withdrawalProof = new bytes[](arrayLength);

        for (uint256 i = 0; i < withdrawalProof.length; ++i) {
            withdrawalProof[i] = freshBytes(600); // abi.encodePacked(freshBytes32());  // abi.encodePacked(kevm.freshUInt(32));
        }
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
