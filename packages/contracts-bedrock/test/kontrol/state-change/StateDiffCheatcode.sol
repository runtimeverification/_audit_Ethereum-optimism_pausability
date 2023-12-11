pragma solidity ^0.8.13;

import { Vm } from "forge-std/Vm.sol";

import 'test/kontrol/state-change/StateDiffCheatcodeCode.sol';

contract StateDiffCheatcode is StateDiffCheatcodeCode {
	// Cheat code address, 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
	address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
	Vm internal constant vm = Vm(VM_ADDRESS);

	address internal constant AddressManagerAddress = 0xDB8cFf278adCCF9E9b5da745B44E754fC4EE3C76;
	address internal constant GuardianAddress = 0x27Dad69D2589059728E8daF9b2FF8557998F3402;
	address internal constant ProxyAdminAddress = 0x50EEf481cae4250d252Ae577A09bF514f224C6C4;
	address internal constant SafeProxyFactoryAddress = 0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496;
	address internal constant SafeSingletonAddress = 0xBb2180ebd78ce97360503434eD37fcf4a1Df61c3;
	address internal constant SuperchainConfigAddress = 0x9D0C592039BFB4e5cd6e25E8E7EeaFE71c892EFF;
	address internal constant SuperchainConfigProxyAddress = 0x62c20Aa1e0272312BC100b4e23B4DC1Ed96dD7D1;
	address internal constant SystemOwnerSafeAddress = 0x5078bed9E03b2CFCA7E78D967f1968D4360E5d07;


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