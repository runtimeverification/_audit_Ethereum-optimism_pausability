// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* import { Vm } from "forge-std/Vm.sol"; */
/* import { VmSafe } from "forge-std/Vm.sol"; */

/* import { Deploy } from "scripts/Deploy.s.sol"; */

import { Safe } from "safe-contracts/Safe.sol";
import { SafeProxyFactory } from "safe-contracts/proxies/SafeProxyFactory.sol";
import { Enum as SafeOps } from "safe-contracts/common/Enum.sol";

import { ProxyAdmin } from "src/universal/ProxyAdmin.sol";
import { AddressManager } from "src/legacy/AddressManager.sol";
import { Proxy } from "src/universal/Proxy.sol";

import { SuperchainConfig } from "src/L1/SuperchainConfig.sol";

import { ProtocolVersions, ProtocolVersion } from "src/L1/ProtocolVersions.sol";

/* import { console2 as console } from "forge-std/console2.sol"; */
/* import { stdJson } from "forge-std/StdJson.sol"; */
/* import { LibStateDiff } from "scripts/libraries/LibStateDiff.sol"; */

import { RecordDeployments } from "./RecordDeployments.sol";

contract SimplifiedDiff is RecordDeployments {

    modifier prankDefaultSender() {
        vm.startPrank(msg.sender);
        _;
        vm.stopPrank();
    }

    ///        bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    bytes32 internal constant OWNER_KEY = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;


    address adminOfTheProxies;
    address payable safeAddress;

    function testSimplifiedDeployment() stateDiff prankDefaultSender public {
        /****************/
        /* deploySafe() */
        /****************/
        (SafeProxyFactory safeProxyFactory, Safe safeSingleton) = _getSafeFactoryLogic();

        address[] memory signers = new address[](1);
        signers[0] = msg.sender;

        bytes memory initData = abi.encodeWithSelector(
                                                       Safe.setup.selector, signers, 1, address(0), hex"", address(0), address(0), 0, address(0)
        );

        address payable safe = payable(address(safeProxyFactory.createProxyWithNonce(address(safeSingleton), initData, block.timestamp))); /* added `payable` */

        safeAddress = safe;
        save("SystemOwnerSafe", safe);

        /*********************/
        /* setupSuperchain() */
        /*********************/

        /* deployAddressManager(); */
        /* ----------------------- */

        AddressManager manager = new AddressManager();
        save("AddressManager", address(manager));

        /* deployProxyAdmin(); */
        /* ------------------- */

        ProxyAdmin admin = new ProxyAdmin({
            _owner: msg.sender
            });
        AddressManager addressManager = manager; /* AddressManager(mustGetAddress("AddressManager")); */
        if (admin.addressManager() != addressManager) {
            admin.setAddressManager(addressManager);
        }

        adminOfTheProxies = address(admin);
        save("ProxyAdmin", address(admin));

        /* transferProxyAdminOwnership(); */
        /* ------------------------------ */

        ProxyAdmin proxyAdmin = admin; /* ProxyAdmin(mustGetAddress("ProxyAdmin")); */
        address owner = proxyAdmin.owner();
        /* address safe = mustGetAddress("SystemOwnerSafe"); */
        if (owner != safe) {
            proxyAdmin.transferOwnership(safe);
        }

        // Deploy the SuperchainConfigProxy
        /* deployERC1967Proxy("SuperchainConfigProxy"); */
        /* -------------------------------------------- */

        address payable superchainConfigProxy = payable(deployERC1967ProxyLogic("SuperchainConfigProxy"));

        /* deploySuperchainConfig(); */
        /* ------------------------- */

        SuperchainConfig superchainConfig = new SuperchainConfig{ salt: "ethers phoenix" /* _implSalt() */ }();

        require(superchainConfig.guardian() == address(0));
        bytes32 initialized = vm.load(address(superchainConfig), bytes32(0));
        require(initialized != 0);

        save("SuperchainConfig", address(superchainConfig));
        address payable superchainConfigPayable = payable(address(superchainConfig));

        /* initializeSuperchainConfig(); */
        /* ----------------------------- */

        /* address payable superchainConfigProxy = mustGetAddress("SuperchainConfigProxy"); */
        /* address payable superchainConfig = mustGetAddress("SuperchainConfig"); */
        _upgradeAndCallViaSafeLogic({
            _proxy: superchainConfigProxy,
            _implementation: superchainConfigPayable,
            _innerCallData: abi.encodeCall(SuperchainConfig.initialize, (stringToAddress("Guardian")/* cfg.superchainConfigGuardian() */, false))
            });
        save("Guardian", stringToAddress("Guardian"));

        /* ChainAssertions.checkSuperchainConfig({ _contracts: _proxiesUnstrict(), _cfg: cfg, _isPaused: false }); */

        /* // Deploy the ProtocolVersionsProxy */
        /* /\* deployERC1967Proxy("ProtocolVersionsProxy"); *\/ */
        /* /\* -------------------------------------------- *\/ */

        /*     address protocolVersionsProxy = deployERC1967ProxyLogic("ProtocolVersionsProxy"); */

        /* /\* deployProtocolVersions(); *\/ */
        /* /\* ------------------------- *\/ */

        /* /\* console.log("Deploying ProtocolVersions implementation"); *\/ */
        /* ProtocolVersions versions = new ProtocolVersions{ salt: "ethers phoenix" /\* _implSalt() *\/ }(); */
        /* /\* save("ProtocolVersions", address(versions)); *\/ */
        /* /\* console.log("ProtocolVersions deployed at %s", address(versions)); *\/ */

        /* // Override the `ProtocolVersions` contract to the deployed implementation. This is necessary */
        /* // to check the `ProtocolVersions` implementation alongside dependent contracts, which */
        /* // are always proxies. */
        /* /\* Types.ContractSet memory contracts = _proxiesUnstrict(); *\/ */
        /* /\* contracts.ProtocolVersions = address(versions); *\/ */
        /* /\* ChainAssertions.checkProtocolVersions({ _contracts: contracts, _cfg: cfg, _isProxy: false }); *\/ */

        /* /\* require(loadInitializedSlot("ProtocolVersions", false) == 1, "ProtocolVersions is not initialized"); *\/ */

        /* /\* addr_ = address(versions); *\/ */

        /* /\* initializeProtocolVersions(); *\/ */
        /* /\* ----------------------------- *\/ */

        /* /\* console.log("Upgrading and initializing ProtocolVersions proxy"); *\/ */
        /* /\* address protocolVersionsProxy = mustGetAddress("ProtocolVersionsProxy"); *\/ */
        /* address protocolVersions = address(versions); /\* mustGetAddress("ProtocolVersions"); *\/ */

        /* address finalSystemOwner = stringToAddress("FinalOwner"); /\* cfg.finalSystemOwner(); *\/ */
        /* save("FinalSystemOwner", finalSystemOwner); */

        /* uint256 requiredProtocolVersion = 1; /\* cfg.requiredProtocolVersion(); *\/ */
        /* uint256 recommendedProtocolVersion = 1; /\* cfg.recommendedProtocolVersion(); *\/ */

        /* _upgradeAndCallViaSafeLogic({ */
        /*     _proxy: payable(protocolVersionsProxy), */
        /*     _implementation: protocolVersions, */
        /*     _innerCallData: abi.encodeCall( */
        /*         ProtocolVersions.initialize, */
        /*         ( */
        /*             finalSystemOwner, */
        /*             ProtocolVersion.wrap(requiredProtocolVersion), */
        /*             ProtocolVersion.wrap(recommendedProtocolVersion) */
        /*         ) */
        /*         ) */
        /* }); */

        /* ProtocolVersions versions = ProtocolVersions(protocolVersionsProxy); */
        /* string memory version = versions.version(); */
        /* console.log("ProtocolVersions version: %s", version); */

        /* ChainAssertions.checkProtocolVersions({ _contracts: _proxiesUnstrict(), _cfg: cfg, _isProxy: true }); */

        /* require(loadInitializedSlot("ProtocolVersions", true) == 1, "ProtocolVersionsProxy is not initialized"); */

    }

    /* Function adaptation to contian only the kontrol friendly logic */

    function deployERC1967ProxyLogic(string memory _name) public returns (address addr_) {
        /* console.log(string.concat("Deploying ERC1967 proxy for", _name, "")); */
        address proxyAdmin = adminOfTheProxies; /* mustGetAddress("ProxyAdmin"); */
        Proxy proxy = new Proxy({
            _admin: proxyAdmin
            });

        address admin = address(uint160(uint256(vm.load(address(proxy), OWNER_KEY))));
        require(admin == proxyAdmin);

        save(_name, address(proxy));
        /* console.log("   at %s", address(proxy)); */
        addr_ = address(proxy);
    }

    function _callViaSafeLogic(address _target, bytes memory _data) internal {
        Safe safe = Safe(safeAddress);

        // This is the signature format used the caller is also the signer.
        bytes memory signature = abi.encodePacked(uint256(uint160(msg.sender)), bytes32(0), uint8(1));

        safe.execTransaction({
            to: _target,
            value: 0,
            data: _data,
            operation: SafeOps.Operation.Call,
            safeTxGas: 0,
            baseGas: 0,
            gasPrice: 0,
            gasToken: address(0),
            refundReceiver: payable(address(0)),
            signatures: signature
        });
    }

    /// @notice Call from the Safe contract to the Proxy Admin's upgrade and call method
    function _upgradeAndCallViaSafeLogic(address _proxy, address _implementation, bytes memory _innerCallData) internal {
        address proxyAdmin = adminOfTheProxies; /* mustGetAddress("ProxyAdmin"); */

        bytes memory data =
            abi.encodeCall(ProxyAdmin.upgradeAndCall, (payable(_proxy), _implementation, _innerCallData));

        _callViaSafeLogic({ _target: proxyAdmin, _data: data });
    }

    function _getSafeFactoryLogic() internal returns (SafeProxyFactory safeProxyFactory_, Safe safeSingleton_) {
        // These are they standard create2 deployed contracts. First we'll check if they are deployed,
        // if not we'll deploy new ones, though not at these addresses.
        address safeProxyFactory = 0xa6B71E26C5e0845f74c812102Ca7114b6a896AB2;
        address safeSingleton = 0xd9Db270c1B5E3Bd161E8c8503c55cEABeE709552;

        safeProxyFactory.code.length == 0
            ? safeProxyFactory_ = new SafeProxyFactory()
            : safeProxyFactory_ = SafeProxyFactory(safeProxyFactory);

        safeSingleton.code.length == 0 ? safeSingleton_ = new Safe() : safeSingleton_ = Safe(payable(safeSingleton));

        save("SafeProxyFactory", address(safeProxyFactory_));
        save("SafeSingleton", address(safeSingleton_));
    }

    /* function test_runHarcodedDeployment() public { */
    /*     vm.startPrank(msg.sender); */
    /*     condensedDeployment(); */
    /* } */
}
