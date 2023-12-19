// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Vm } from "forge-std/Vm.sol";
import { KontrolCheats } from "kontrol-cheatcodes/KontrolCheats.sol";

contract GhostBytes1 {
    bytes public ghostBytes;
}

contract GhostBytesArray10 {
    bytes public ghostBytes0;
    bytes public ghostBytes1;
    bytes public ghostBytes2;
    bytes public ghostBytes3;
    bytes public ghostBytes4;
    bytes public ghostBytes5;
    bytes public ghostBytes6;
    bytes public ghostBytes7;
    bytes public ghostBytes8;
    bytes public ghostBytes9;

    function getGhostBytesArray() public view returns (bytes[] memory _arr) {
        _arr = new bytes[](10);
        _arr[0] = ghostBytes0;
        _arr[1] = ghostBytes1;
        _arr[2] = ghostBytes2;
        _arr[3] = ghostBytes3;
        _arr[4] = ghostBytes4;
        _arr[5] = ghostBytes5;
        _arr[6] = ghostBytes6;
        _arr[7] = ghostBytes7;
        _arr[8] = ghostBytes8;
        _arr[9] = ghostBytes9;
    }
}

contract Workarounds is KontrolCheats {
    address private constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
    Vm private constant vm = Vm(VM_ADDRESS);

    function freshBigBytes(uint256 bytesLength) internal returns (bytes memory sBytes) {
        require(bytesLength >= 32, "Small bytes");

        uint256 bytesSlotValue;
        unchecked {
            bytesSlotValue = bytesLength * 2 + 1;
        }

        /* Deploy ghost contract */
        GhostBytes1 ghostBytes = new GhostBytes1();

        /* Make the storage of the ghost contract symbolic */
        kevm.symbolicStorage(address(ghostBytes));

        /* Load the size encoding into the first slot of ghostBytes*/
        vm.store(address(ghostBytes), bytes32(uint256(0)), bytes32(bytesSlotValue));

        sBytes = ghostBytes.ghostBytes();
    }

    function freshBytesArray() public returns (bytes[] memory) {
        /* Length of the returned bytes array */
        /* uint256 arrayLength = 10; */

        /* bytes[] memory bytesArray = new bytes[](arrayLength); */

        /* Deploy ghost contract */
        GhostBytesArray10 ghostBytes10 = new GhostBytesArray10();

        /* Make the storage of the ghost contract symbolic */
        kevm.symbolicStorage(address(ghostBytes10));

        /* Each bytes element will have a length of 600 */
        uint256 bytesSlotValue = 600 * 2 + 1;

        /* Load the size encoding into the first slot of ghostBytes*/
        vm.store(address(ghostBytes10), bytes32(uint256(0)), bytes32(bytesSlotValue));
        vm.store(address(ghostBytes10), bytes32(uint256(1)), bytes32(bytesSlotValue));
        vm.store(address(ghostBytes10), bytes32(uint256(2)), bytes32(bytesSlotValue));
        vm.store(address(ghostBytes10), bytes32(uint256(3)), bytes32(bytesSlotValue));
        vm.store(address(ghostBytes10), bytes32(uint256(4)), bytes32(bytesSlotValue));
        vm.store(address(ghostBytes10), bytes32(uint256(5)), bytes32(bytesSlotValue));
        vm.store(address(ghostBytes10), bytes32(uint256(6)), bytes32(bytesSlotValue));
        vm.store(address(ghostBytes10), bytes32(uint256(7)), bytes32(bytesSlotValue));
        vm.store(address(ghostBytes10), bytes32(uint256(8)), bytes32(bytesSlotValue));
        vm.store(address(ghostBytes10), bytes32(uint256(9)), bytes32(bytesSlotValue));

        return ghostBytes10.getGhostBytesArray();
    }

    function test_workaround1() public {
        bytes[] memory symbolicBytes = freshBytesArray();
        require(symbolicBytes.length == 10, "Length should be 10");
    }

    function test_workaround2() public {
        bytes[] memory symbolicBytes = new bytes[](10);

        for (uint256 i = 0; i < symbolicBytes.length; ++i) {
            symbolicBytes[i] = freshBigBytes(600);
        }
        require(symbolicBytes.length == 10, "Length should be 10");
    }

    function test_workaround3() public {
        bytes[] memory symbolicBytes = new bytes[](1);
        symbolicBytes[0] = freshBigBytes(600);
    }

}
