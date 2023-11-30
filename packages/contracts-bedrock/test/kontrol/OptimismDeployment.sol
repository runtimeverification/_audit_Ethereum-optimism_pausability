// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Test } from "forge-std/Test.sol";
import { console2 as console } from "forge-std/console2.sol";
import { Vm } from "forge-std/Vm.sol";
import { AddressManager } from "src/legacy/AddressManager.sol";
import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { Proxy } from "src/universal/Proxy.sol";
import {OptimismPortal} from "src/L1/OptimismPortal.sol";


/*********************************************************************/
/* Modifications made:                                               */
/* - Removed `broadcast` modifier                                    */
/* - Removded `console.log` instances                                */
/* - Removed call to `_getExistingDeploymentAddress` in `getAddress` */
/* - Call to `_writeTemp` in `save`                                  */
/* - In `implSalt`, removed `vm.envOr` in favor of the default case  */
/*********************************************************************/

/// @notice store the new deployment to be saved
struct Deployment {
    string name;
    address payable addr;
}

abstract contract DeployerSimplified /* is Test */ {

    /// @dev we only care about the vm signature
    // Cheat code address, 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D.
    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
    Vm internal constant vm = Vm(VM_ADDRESS);

    /// @notice The set of deployments that have been done during execution.
    mapping(string => Deployment) internal _namedDeployments;
    /// @notice The same as `_namedDeployments` but as an array.
    Deployment[] internal _newDeployments;

    error DeploymentDoesNotExist(string);
    /// @notice Error for when trying to save an invalid deployment
    error InvalidDeployment(string);
    /// @notice The storage slot that holds the address of the implementation.
    ///        bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)

    bytes32 internal constant IMPLEMENTATION_KEY = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    /// @notice The storage slot that holds the address of the owner.
    ///        bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    bytes32 internal constant OWNER_KEY = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

     /// @notice Returns the address of a deployment.
    /// @param _name The name of the deployment.
    /// @return The address of the deployment. May be `address(0)` if the deployment does not
    ///         exist.
    function getAddress(string memory _name) public view returns (address payable) {
        Deployment memory existing = _namedDeployments[_name];
        if (existing.addr != address(0)) {
            if (bytes(existing.name).length == 0) {
                return payable(address(0));
            }
            return existing.addr;
        }
        /* return _getExistingDeploymentAddress(_name); */
        ///@notice We revert since this simplified set up should always enter the above if clause
        assert(false);
    }

    /// @notice Returns the address of a deployment and reverts if the deployment
    ///         does not exist.
    /// @return The address of the deployment.
    function mustGetAddress(string memory _name) public view returns (address payable) {
        address addr = getAddress(_name);
        if (addr == address(0)) {
            revert DeploymentDoesNotExist(_name);
        }
        return payable(addr);
    }

    /// @notice Writes a deployment to disk as a temp deployment so that the
    ///         hardhat deploy artifact can be generated afterwards.
    /// @param _name The name of the deployment.
    /// @param _deployed The address of the deployment.
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
        ///@notice this is removed from the original implementation, too much overhead
        /* _writeTemp(_name, _deployed); */
    }

    /// @notice Reads the artifact from the filesystem by name and returns the address.
    /// @param _name The name of the artifact to read.
    /// @return The address of the artifact.
    /* function _getExistingDeploymentAddress(string memory _name) internal view returns (address payable) { */
    /*     return _getExistingDeployment(_name).addr; */
    /* } */

    /// @notice Reads the artifact from the filesystem by name and returns the Deployment.
    /// @param _name The name of the artifact to read.
    /// @return The deployment corresponding to the name.
    /* function _getExistingDeployment(string memory _name) internal view returns (Deployment memory) { */
    /*     string memory path = string.concat(deploymentsDir, "/", _name, ".json"); */
    /*     try vm.readFile(path) returns (string memory json) { */
    /*         bytes memory addr = stdJson.parseRaw(json, "$.address"); */
    /*         return Deployment({ addr: abi.decode(addr, (address)), name: _name }); */
    /*     } catch { */
    /*         return Deployment({ addr: payable(address(0)), name: "" }); */
    /*     } */
    /* } */

}

abstract contract DeploymentScriptSimplified is DeployerSimplified {

    /// @notice The create2 salt used for deployment of the contract implementations.
    ///         Using this helps to reduce config across networks as the implementation
    ///         addresses will be the same across networks when deployed with create2.
    /// @notice Removed the `vm.envOr` in favor of the default case
    function implSalt() internal returns (bytes32) {
        /* return keccak256(bytes(vm.envOr("IMPL_SALT", string("ethers phoenix")))); */
        return keccak256(bytes(string("ethers phoenix")));
    }

    /// @notice Deploy the AddressManager
    /// @notice Removed broadcast modifier and console.log from original function
    function deployAddressManager() public /* broadcast */ returns (address addr_) {
        AddressManager manager = new AddressManager();
        console.log(manager.owner(), "owner");
        console.log(msg.sender, "sender");
        require(manager.owner() == msg.sender);

        save("AddressManager", address(manager));
        /* console.log("AddressManager deployed at %s", address(manager)); */
        addr_ = address(manager);
    }

    /// @notice Deploy the ProxyAdmin
    /// @notice Removed broadcast modifier and console.log from original function
    function deployProxyAdmin() public /* broadcast */ returns (address addr_) {
        ProxyAdmin admin = new ProxyAdmin({
            _owner: msg.sender
            });
        require(admin.owner() == msg.sender);

        AddressManager addressManager = AddressManager(mustGetAddress("AddressManager"));
        if (admin.addressManager() != addressManager) {
            admin.setAddressManager(addressManager);
        }

        require(admin.addressManager() == addressManager);

        save("ProxyAdmin", address(admin));
        /* console.log("ProxyAdmin deployed at %s", address(admin)); */
        addr_ = address(admin);
    }

    /// @notice Deploy the OptimismPortalProxy
    /// @notice Removed broadcast modifier and console.log from original function
    function deployOptimismPortalProxy() public /* broadcast */ returns (address addr_) {
        address proxyAdmin = mustGetAddress("ProxyAdmin");
        Proxy proxy = new Proxy({
            _admin: proxyAdmin
            });

        address admin = address(uint160(uint256(vm.load(address(proxy), OWNER_KEY))));
        require(admin == proxyAdmin);

        save("OptimismPortalProxy", address(proxy));
        /* console.log("OptimismPortalProxy deployed at %s", address(proxy)); */

        addr_ = address(proxy);
    }

    /// @notice Transfer ownership of the address manager to the ProxyAdmin
    /// @notice Removed broadcast modifier and console.log from original function
    function transferAddressManagerOwnership() public /* broadcast */ {
        AddressManager addressManager = AddressManager(mustGetAddress("AddressManager"));
        address owner = addressManager.owner();
        address proxyAdmin = mustGetAddress("ProxyAdmin");
        if (owner != proxyAdmin) {
            addressManager.transferOwnership(proxyAdmin);
            /* console.log("AddressManager ownership transferred to %s", proxyAdmin); */
        }

        require(addressManager.owner() == proxyAdmin);
    }

    /// @notice Deploy the OptimismPortal
    /// @notice Removed broadcast modifier and console.log from original function
    function deployOptimismPortal() public /* broadcast */ returns (address addr_) {
        OptimismPortal portal = new OptimismPortal{ salt: implSalt() }();

        require(address(portal.L2_ORACLE()) == address(0));
        require(portal.GUARDIAN() == address(0));
        require(address(portal.SYSTEM_CONFIG()) == address(0));
        require(portal.paused() == true);

        save("OptimismPortal", address(portal));
        /* console.log("OptimismPortal deployed at %s", address(portal)); */

        addr_ = address(portal);
    }

    /// @notice Deploy all of the proxies
    function deployProxies() public {
        deployAddressManager();
        deployProxyAdmin();

        deployOptimismPortalProxy();
        /* deployL2OutputOracleProxy(); */
        /* deploySystemConfigProxy(); */
        /* deployL1StandardBridgeProxy(); */
        /* deployL1CrossDomainMessengerProxy(); */
        /* deployOptimismMintableERC20FactoryProxy(); */
        /* deployL1ERC721BridgeProxy(); */
        /* deployDisputeGameFactoryProxy(); */
        /* deployProtocolVersionsProxy(); */

        transferAddressManagerOwnership(); // to the ProxyAdmin
    }

    /// @notice Deploy all of the implementations
    function deployImplementations() public {
        deployOptimismPortal();
        /* deployL1CrossDomainMessenger(); */
        /* deployL2OutputOracle(); */
        /* deployOptimismMintableERC20Factory(); */
        /* deploySystemConfig(); */
        /* deployL1StandardBridge(); */
        /* deployL1ERC721Bridge(); */
        /* deployDisputeGameFactory(); */
        /* deployBlockOracle(); */
        /* deployPreimageOracle(); */
        /* deployMips(); */
        /* deployProtocolVersions(); */
    }

    /// @notice Deploy all of the L1 contracts
    function deployL1() public {
        /* console.log("Deploying L1 system"); */

        /* deployProxies(); */
        /* Deploy Addressmanager */
        AddressManager manager = new AddressManager();
        /* console.log(manager.owner(), "owner"); */
        /* console.log(msg.sender, "sender"); */
        /* require(manager.owner() == msg.sender); */

        save("AddressManager", address(manager));
        /* console.log("AddressManager deployed at %s", address(manager)); */
        /* addr_ = address(manager); */

        /* Deploy ProxyAdmin */
        ProxyAdmin admin = new ProxyAdmin({
            _owner: msg.sender
            });
        /* require(admin.owner() == msg.sender); */

        AddressManager addressManager = AddressManager(mustGetAddress("AddressManager"));
        if (admin.addressManager() != addressManager) {
            console.log(admin.owner(), "admin.owner");
            console.log(msg.sender, "msg.sender");
            admin.setAddressManager(addressManager);
        }

        require(admin.addressManager() == addressManager);

        save("ProxyAdmin", address(admin));
        /* console.log("ProxyAdmin deployed at %s", address(admin)); */
        /* addr_ = address(admin); */

        /* Deploy OptimismPortal */
        OptimismPortal portal = new OptimismPortal{ salt: implSalt() }();

        require(address(portal.L2_ORACLE()) == address(0));
        require(portal.GUARDIAN() == address(0));
        require(address(portal.SYSTEM_CONFIG()) == address(0));
        require(portal.paused() == true);

        save("OptimismPortal", address(portal));
        /* console.log("OptimismPortal deployed at %s", address(portal)); */

        /* addr_ = address(portal); */


        /* deployImplementations(); */

        /* deploySafe(); */
        /* transferProxyAdminOwnership(); // to the Safe */

        /* initializeDisputeGameFactory(); */
        /* initializeSystemConfig(); */
        /* initializeL1StandardBridge(); */
        /* initializeL1ERC721Bridge(); */
        /* initializeOptimismMintableERC20Factory(); */
        /* initializeL1CrossDomainMessenger(); */
        /* initializeL2OutputOracle(); */
        /* initializeOptimismPortal(); */
        /* initializeProtocolVersions(); */

        /* setAlphabetFaultGameImplementation(); */
        /* setCannonFaultGameImplementation(); */

        /* transferDisputeGameFactoryOwnership(); */
    }

    /// @notice Initialize the OptimismPortal
    /* function initializeOptimismPortal() public /\* broadcast *\/ { */
    /*     address optimismPortalProxy = mustGetAddress("OptimismPortalProxy"); */
    /*     address optimismPortal = mustGetAddress("OptimismPortal"); */
    /*     /\* address l2OutputOracleProxy = mustGetAddress("L2OutputOracleProxy"); *\/ */
    /*     /\* address systemConfigProxy = mustGetAddress("SystemConfigProxy"); *\/ */

    /*     address guardian = cfg.portalGuardian(); */
    /*     /\* if (guardian.code.length == 0) { *\/ */
    /*     /\*     console.log("Portal guardian has no code: %s", guardian); *\/ */
    /*     /\* } *\/ */

    /*     _upgradeAndCallViaSafe({ */
    /*         _proxy: payable(optimismPortalProxy), */
    /*         _implementation: optimismPortal, */
    /*         _innerCallData: abi.encodeCall( */
    /*             OptimismPortal.initialize, */
    /*             (L2OutputOracle(l2OutputOracleProxy), guardian, SystemConfig(systemConfigProxy), false) */
    /*             ) */
    /*     }); */

    /*     OptimismPortal portal = OptimismPortal(payable(optimismPortalProxy)); */
    /*     string memory version = portal.version(); */
    /*     /\* console.log("OptimismPortal version: %s", version); *\/ */

    /*     ChainAssertions.checkOptimismPortal(_proxies(), cfg); */
    /* } */

}

contract TestDeployment is DeploymentScriptSimplified {

    address public defaultOwner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;//vm.addr(uint256(bytes32("owner")));
    function testDeploymentStuff() public {
        /* vm.label(defaultOwner, "dfown"); */
        vm.startPrank(defaultOwner,defaultOwner);
        deployL1();
        /* console.log(defaultOwner, "dfown"); */
        /* deployAddressManager(); */
        /* deployProxyAdmin(); */
        /* AddressManager manager = new AddressManager(); */
        /* console.log(manager.owner(), "owner"); */
        /* console.log(msg.sender, "sender"); */
        /* require(manager.owner() == msg.sender); */

        /* deployOptimismPortalProxy(); */
        vm.stopPrank();
    }
}
