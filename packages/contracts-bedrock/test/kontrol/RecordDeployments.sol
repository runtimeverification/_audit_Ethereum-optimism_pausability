// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Vm } from "forge-std/Vm.sol";
import { VmSafe } from "forge-std/Vm.sol";

import { stdJson } from "forge-std/StdJson.sol";
import { console2 as console } from "forge-std/console2.sol";

import { LibStateDiff } from "scripts/libraries/LibStateDiff.sol";

struct Deployment {
    string name;
    address payable addr;
}

abstract contract RecordDeployments {

    function name() public pure /* override */ returns (string memory name_) {
        name_ = "Deploy";
    }

    modifier stateDiff() {
        vm.startStateDiffRecording();
        _;
        VmSafe.AccountAccess[] memory accesses = vm.stopAndReturnStateDiff();
        console.log("Writing %d state diff account accesses to snapshots/state-diff/%s.json", accesses.length, name());
        string memory json = LibStateDiff.encodeAccountAccesses(accesses);
        string memory statediffPath = string.concat(vm.projectRoot(), "/snapshots/state-diff/", name(), ".json");
        vm.writeJson({ json: json, path: statediffPath });
    }

	// Cheat code address, 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
	address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
	Vm internal constant vm = Vm(VM_ADDRESS);

    /// @notice The set of deployments that have been done during execution.
    mapping(string => Deployment) internal _namedDeployments;
    /// @notice The same as `_namedDeployments` but as an array.
    Deployment[] internal _newDeployments;

    string internal deploymentsDir;
    /// @notice The namespace for the deployment. Can be set with the env var DEPLOYMENT_CONTEXT.
    string internal deploymentContext;
    /// @notice The path to the temp deployments file
    string internal tempDeploymentsPath;

    /// @notice Error for when trying to save an invalid deployment
    error InvalidDeployment(string);

    function setUp() public virtual {
        string memory root = vm.projectRoot();
        deploymentContext = vm.envOr("DEPLOYMENT_CONTEXT", string("hardhat"));
        deploymentsDir = string.concat(root, "/deployments/", deploymentContext);

        tempDeploymentsPath = string.concat(deploymentsDir, "/.deploy");
        try vm.readFile(tempDeploymentsPath) returns (string memory) { }
        catch {
            vm.writeJson("{}", tempDeploymentsPath);
        }
        console.log("Storing temp deployment data in %s", tempDeploymentsPath);
    }

    function save(string memory _name, address _deployed) public {
        if (bytes(_name).length == 0) {
            revert InvalidDeployment("EmptyName");
        }
        if (bytes(_namedDeployments[_name].name).length > 0) {
            revert InvalidDeployment("AlreadyExists");
        }

        Deployment memory deployment = Deployment({ name: _name, addr: payable(_deployed) });
        _namedDeployments[_name] = deployment;
        _newDeployments.push(deployment);
        _writeTemp(_name, _deployed);
    }

    function _writeTemp(string memory _name, address _deployed) internal {
        vm.writeJson({ json: stdJson.serialize("", _name, _deployed), path: tempDeploymentsPath });
    }

    function stringToAddress(string memory _str) internal pure returns (address _addr) {
        _addr = address(uint160(uint256(keccak256(bytes(_str)))));
    }


}
