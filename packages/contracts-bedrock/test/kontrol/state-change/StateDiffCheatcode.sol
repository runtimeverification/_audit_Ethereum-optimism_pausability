pragma solidity ^0.8.13;

import { Vm } from "forge-std/Vm.sol";

import 'test/kontrol/state-change/StateDiffCheatcodeCode.sol';

contract StateDiffCheatcode is StateDiffCheatcodeCode {
	// Cheat code address, 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
	address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
	Vm internal constant vm = Vm(VM_ADDRESS);

	address internal constant AddressManagerAddress = 0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3;
	address internal constant L2OutputOracleAddress = 0x1B9F0e648A0A4780120A6Cd07B952F76560c8F8b;
	address internal constant L2OutputOracleProxyAddress = 0x8B71b41D4dBEb2b6821d44692d3fACAAf77480Bb;
	address internal constant OptimismPortalAddress = 0xF0A8903b331864E0Caf270C6DaDfBCa74Cb0b78A;
	address internal constant OptimismPortalProxyAddress = 0x978e3286EB805934215a88694d80b09aDed68D90;
	address internal constant ProtocolVersionsAddress = 0xfbfD64a6C0257F613feFCe050Aa30ecC3E3d7C3F;
	address internal constant ProtocolVersionsProxyAddress = 0x416C42991d05b31E9A6dC209e91AD22b79D87Ae6;
	address internal constant ProxyAdminAddress = 0xDB8cFf278adCCF9E9b5da745B44E754fC4EE3C76;
	address internal constant SafeProxyFactoryAddress = 0x34A1D3fff3958843C43aD80F30b94c510645C316;
	address internal constant SafeSingletonAddress = 0x90193C961A926261B756D1E5bb255e67ff9498A1;
	address internal constant SuperchainConfigAddress = 0x068E44eB31e111028c41598E4535be7468674D0A;
	address internal constant SuperchainConfigProxyAddress = 0xDEb1E9a6Be7Baf84208BB6E10aC9F9bbE1D70809;
	address internal constant SystemConfigAddress = 0xc7B87b2b892EA5C3CfF47168881FE168C00377FB;
	address internal constant SystemConfigProxyAddress = 0x1c23A6d89F95ef3148BCDA8E242cAb145bf9c0E4;
	address internal constant SystemOwnerSafeAddress = 0x2601573C28B77dea6C8B73385c25024A28a00C3F;
	address internal constant acc15Address = 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f;


	function recreateDeployment() public {
		bytes32 slot;
		bytes32 value;
		vm.etch(SafeProxyFactoryAddress, SafeProxyFactoryCode);
		vm.etch(SafeSingletonAddress, SafeSingletonCode);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000004';
		value = hex'0000000000000000000000000000000000000000000000000000000000000001';
		vm.store(SafeSingletonAddress, slot, value);
		vm.etch(SystemOwnerSafeAddress, SystemOwnerSafeCode);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000000';
		value = hex'000000000000000000000000bb2180ebd78ce97360503434ed37fcf4a1df61c3';
		vm.store(SystemOwnerSafeAddress, slot, value);
		slot = hex'e90b7bceb6e7df5418fb78d8ee546e97c83a08bbccc01a0644d599ccd2a7c2e0';
		value = hex'0000000000000000000000001804c8ab1f12e6bbf3894d4083f33e07309d1f38';
		vm.store(SystemOwnerSafeAddress, slot, value);
		slot = hex'd1b0d319c6526317dce66989b393dcfb4435c9a65e399a088b63bbf65d7aee32';
		value = hex'0000000000000000000000000000000000000000000000000000000000000001';
		vm.store(SystemOwnerSafeAddress, slot, value);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000003';
		value = hex'0000000000000000000000000000000000000000000000000000000000000001';
		vm.store(SystemOwnerSafeAddress, slot, value);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000004';
		value = hex'0000000000000000000000000000000000000000000000000000000000000001';
		vm.store(SystemOwnerSafeAddress, slot, value);
		slot = hex'cc69885fda6bcc1a4ace058b4a62bf5e179ea78fd58a1ccd71c22cc9b688792f';
		value = hex'0000000000000000000000000000000000000000000000000000000000000001';
		vm.store(SystemOwnerSafeAddress, slot, value);
		vm.etch(AddressManagerAddress, AddressManagerCode);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000000';
		value = hex'0000000000000000000000001804c8ab1f12e6bbf3894d4083f33e07309d1f38';
		vm.store(AddressManagerAddress, slot, value);
		vm.etch(ProxyAdminAddress, ProxyAdminCode);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000000';
		value = hex'0000000000000000000000001804c8ab1f12e6bbf3894d4083f33e07309d1f38';
		vm.store(ProxyAdminAddress, slot, value);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000003';
		value = hex'000000000000000000000000db8cff278adccf9e9b5da745b44e754fc4ee3c76';
		vm.store(ProxyAdminAddress, slot, value);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000000';
		value = hex'0000000000000000000000005078bed9e03b2cfca7e78d967f1968d4360e5d07';
		vm.store(ProxyAdminAddress, slot, value);
		vm.etch(SuperchainConfigProxyAddress, SuperchainConfigProxyCode);
		slot = hex'b53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103';
		value = hex'00000000000000000000000050eef481cae4250d252ae577a09bf514f224c6c4';
		vm.store(SuperchainConfigProxyAddress, slot, value);
		vm.etch(SuperchainConfigAddress, SuperchainConfigCode);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000000';
		value = hex'0000000000000000000000000000000000000000000000000000000000000001';
		vm.store(SuperchainConfigAddress, slot, value);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000000';
		value = hex'0000000000000000000000000000000000000000000000000000000000000101';
		vm.store(SuperchainConfigAddress, slot, value);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000000';
		value = hex'0000000000000000000000000000000000000000000000000000000000000001';
		vm.store(SuperchainConfigAddress, slot, value);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000005';
		value = hex'0000000000000000000000000000000000000000000000000000000000000001';
		vm.store(SystemOwnerSafeAddress, slot, value);
		slot = hex'360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc';
		value = hex'0000000000000000000000009d0c592039bfb4e5cd6e25e8e7eeafe71c892eff';
		vm.store(SuperchainConfigProxyAddress, slot, value);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000000';
		value = hex'0000000000000000000000000000000000000000000000000000000000000001';
		vm.store(SuperchainConfigProxyAddress, slot, value);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000000';
		value = hex'0000000000000000000000000000000000000000000000000000000000000101';
		vm.store(SuperchainConfigProxyAddress, slot, value);
		slot = hex'd30e835d3f35624761057ff5b27d558f97bd5be034621e62240e5c0b784abe68';
		value = hex'00000000000000000000000027dad69d2589059728e8daf9b2ff8557998f3402';
		vm.store(SuperchainConfigProxyAddress, slot, value);
		slot = hex'0000000000000000000000000000000000000000000000000000000000000000';
		value = hex'0000000000000000000000000000000000000000000000000000000000000001';
		vm.store(SuperchainConfigProxyAddress, slot, value);
	}
}
