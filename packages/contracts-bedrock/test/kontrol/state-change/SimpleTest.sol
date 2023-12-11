pragma solidity ^0.8.13;

/* import { StateDiffCheatcode } from "./StateDiffCheatcode.sol"; */
import { KontrolUtils } from "./KontrolUtils.sol";
import { Types } from "src/libraries/Types.sol";
import { OptimismPortalInterface as OptimismPortal, SuperchainConfigInterface as SuperchainConfig} from "./interfaces/KontrolInterfaces.sol";
/* import { console2 as console } from "forge-std/console2.sol"; */
import 'test/kontrol/state-change/StateDiffCheatcodeCode.sol';

contract SimpleTest is StateDiffCheatcodeCode, KontrolUtils {

    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
	Vm internal constant vm = Vm(VM_ADDRESS);

    OptimismPortal optimismPortal;

    function testSimple(/* uint256 _tx0, */
                        address _tx1,
                        address _tx2,
                        /* uint256 _tx3, */
                        uint256 _tx4,
                        /* bytes   memory _tx5, */
                        uint256 _l2OutputIndex,
                        /* OutputRootProof args */
                        bytes32 _outputRootProof0,
                        bytes32 _outputRootProof1,
                        bytes32 _outputRootProof2,
                        bytes32 _outputRootProof3) public {

        /* Reproduce deployment of OptimismPortal */
        /* bytes32 slot; */
		/* bytes32 value; */

        /* address OptimismPortalAddress = 0xF0A8903b331864E0Caf270C6DaDfBCa74Cb0b78A; */
        /* optimismPortal = OptimismPortal(OptimismPortalAddress); */
        /* vm.etch(OptimismPortalAddress, OptimismPortalCode); */
		/* slot = hex'0000000000000000000000000000000000000000000000000000000000000000'; */
		/* value = hex'0000000000000000000000000000000000000000000000000000000000000001'; */
		/* vm.store(OptimismPortalAddress, slot, value); */
		/* slot = hex'0000000000000000000000000000000000000000000000000000000000000000'; */
		/* value = hex'0000000000000000000000000000000000000000000000000000000000000101'; */
		/* vm.store(OptimismPortalAddress, slot, value); */
		/* slot = hex'0000000000000000000000000000000000000000000000000000000000000032'; */
		/* value = hex'000000000000000000000000000000000000000000000000000000000000dead'; */
		/* vm.store(OptimismPortalAddress, slot, value); */
		/* slot = hex'0000000000000000000000000000000000000000000000000000000000000001'; */
		/* value = hex'000000000000000100000000000000000000000000000000000000003b9aca00'; */
		/* vm.store(OptimismPortalAddress, slot, value); */
		/* slot = hex'0000000000000000000000000000000000000000000000000000000000000000'; */
		/* value = hex'0000000000000000000000000000000000000000000000000000000000000001'; */
		/* vm.store(OptimismPortalAddress, slot, value); */

        /* Silly withdrawal proof */
        bytes[] memory _withdrawalProof = new bytes[](1);
        _withdrawalProof[0] = abi.encode(/* kevm.freshUInt(32) */);

        /* Create the rest of the arguments */
        Types.WithdrawalTransaction memory _tx = createWithdrawalTransaction (
            kevm.freshUInt(32) /* _tx0 */,
             _tx1,
             _tx2,
            kevm.freshUInt(32) /* _tx3 */,
             _tx4,
             abi.encode(kevm.freshUInt(32))/* _tx5 */
        );
        Types.OutputRootProof memory _outputRootProof = Types.OutputRootProof(
            _outputRootProof0,
            _outputRootProof1,
            _outputRootProof2,
            _outputRootProof3
        );

        optimismPortal.proveWithdrawalTransaction(
           _tx,
           _l2OutputIndex,
           _outputRootProof,
           _withdrawalProof
        );

    }

}
