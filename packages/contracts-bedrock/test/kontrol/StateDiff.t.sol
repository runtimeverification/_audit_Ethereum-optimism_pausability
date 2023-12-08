pragma solidity 0.8.15;

import "./StateDiffCheatcode.sol";

contract StateDiffTest is StateDiffCheatcode {
    function setUp() public {
        recreateDeployment();
    }

    function testVerifyStateChange() public { }
}
