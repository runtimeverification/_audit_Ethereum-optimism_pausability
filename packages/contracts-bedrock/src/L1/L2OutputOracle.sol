// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ISemver } from "src/universal/ISemver.sol";
import { Types } from "src/libraries/Types.sol";
import { SystemConfig } from "src/L1/SystemConfig.sol";

/// @custom:proxied
/// @title L2OutputOracle
/// @notice The L2OutputOracle contains an array of L2 state outputs, where each output is a
///         commitment to the state of the L2 chain. Other contracts like the OptimismPortal use
///         these outputs to verify information about the state of L2.
contract L2OutputOracle is Initializable, ISemver {
    /// @notice The interval in L2 blocks at which checkpoints must be submitted.
    ///         Although this is immutable, it can safely be modified by upgrading the
    ///         implementation contract.
    ///         Public getter is legacy and will be removed in the future. Use `submissionInterval`
    ///         instead.
    /// @custom:legacy
    uint256 public immutable SUBMISSION_INTERVAL;

    /// @notice The time between L2 blocks in seconds. Once set, this value MUST NOT be modified.
    ///         Public getter is legacy and will be removed in the future. Use `l2BlockTime`
    ///         instead.
    /// @custom:legacy
    uint256 public immutable L2_BLOCK_TIME;

    /// @notice The minimum time (in seconds) that must elapse before a withdrawal can be finalized.
    ///         Public getter is legacy and will be removed in the future. Use
    //          `finalizationPeriodSeconds` instead.
    /// @custom:legacy
    uint256 public immutable FINALIZATION_PERIOD_SECONDS;

    /// @notice The number of the first L2 block recorded in this contract.
    uint256 public startingBlockNumber;

    /// @notice The timestamp of the first L2 block recorded in this contract.
    uint256 public startingTimestamp;

    /// @notice An array of L2 output proposals.
    Types.OutputProposal[] internal l2Outputs;

    /// @notice The address of the System Config. Can be updated via reinitialize.
    /// @custom:network-specific
    /// @custom:legacy-overwrite challenger
    SystemConfig public systemConfig;

    /// @custom:legacy
    /// @custom:spacer proposer
    /// @notice Spacer for backwards compatibility.
    address private spacer_5_0_20;

    /// @notice Emitted when an output is proposed.
    /// @param outputRoot    The output root.
    /// @param l2OutputIndex The index of the output in the l2Outputs array.
    /// @param l2BlockNumber The L2 block number of the output root.
    /// @param l1Timestamp   The L1 timestamp when proposed.
    event OutputProposed(
        bytes32 indexed outputRoot, uint256 indexed l2OutputIndex, uint256 indexed l2BlockNumber, uint256 l1Timestamp
    );

    /// @notice Emitted when outputs are deleted.
    /// @param prevNextOutputIndex Next L2 output index before the deletion.
    /// @param newNextOutputIndex  Next L2 output index after the deletion.
    event OutputsDeleted(uint256 indexed prevNextOutputIndex, uint256 indexed newNextOutputIndex);

    /// @notice Semantic version.
    /// @custom:semver 1.5.1
    string public constant version = "1.5.1";

    /// @notice Constructs the L2OutputOracle contract.
    /// @param _submissionInterval  Interval in blocks at which checkpoints must be submitted.
    /// @param _l2BlockTime         The time per L2 block, in seconds.
    /// @param _finalizationPeriodSeconds The amount of time that must pass for an output proposal
    //                                    to be considered canonical.
    constructor(uint256 _submissionInterval, uint256 _l2BlockTime, uint256 _finalizationPeriodSeconds) {
        require(_l2BlockTime > 0, "L2OutputOracle: L2 block time must be greater than 0");
        require(_submissionInterval > 0, "L2OutputOracle: submission interval must be greater than 0");

        SUBMISSION_INTERVAL = _submissionInterval;
        L2_BLOCK_TIME = _l2BlockTime;
        FINALIZATION_PERIOD_SECONDS = _finalizationPeriodSeconds;

        initialize({ _startingBlockNumber: 0, _startingTimestamp: 0, _systemConfig: SystemConfig(address(0)) });
    }

    /// @notice Initializer.
    /// @param _startingBlockNumber Block number for the first recoded L2 block.
    /// @param _startingTimestamp   Timestamp for the first recoded L2 block.
    /// @param _systemConfig        The address of the system config.
    function initialize(
        uint256 _startingBlockNumber,
        uint256 _startingTimestamp,
        SystemConfig _systemConfig
    )
        public
        reinitializer(2)
    {
        require(
            _startingTimestamp <= block.timestamp,
            "L2OutputOracle: starting L2 timestamp must be less than current time"
        );

        startingTimestamp = _startingTimestamp;
        startingBlockNumber = _startingBlockNumber;
        systemConfig = _systemConfig;

        // Delete the proposer value which is no longer stored in this contract.
        spacer_5_0_20 = address(0);
    }

    /// @notice Getter for the output proposal submission interval.
    function submissionInterval() external view returns (uint256) {
        return SUBMISSION_INTERVAL;
    }

    /// @notice Getter for the L2 block time.
    function l2BlockTime() external view returns (uint256) {
        return L2_BLOCK_TIME;
    }

    /// @notice Getter for the finalization period.
    function finalizationPeriodSeconds() external view returns (uint256) {
        return FINALIZATION_PERIOD_SECONDS;
    }

    /// @notice Getter for the challenger address. This will be removed
    ///         in the future, use `challenger` instead.
    /// @custom:legacy
    function CHALLENGER() external view returns (address) {
        return systemConfig.challenger();
    }

    /// @notice Getter for the challenger address.
    function challenger() external view returns (address) {
        return systemConfig.challenger();
    }

    /// @notice Getter for the proposer address. This will be removed in the
    ///         future, use `proposer` instead.
    /// @custom:legacy
    function PROPOSER() external view returns (address) {
        return systemConfig.proposer();
    }

    /// @notice Getter for the proposer address.
    function proposer() external view returns (address) {
        return systemConfig.proposer();
    }

    /// @notice Deletes all output proposals after and including the proposal that corresponds to
    ///         the given output index. Only the challenger address can delete outputs.
    /// @param _l2OutputIndex Index of the first L2 output to be deleted.
    ///                       All outputs after this output will also be deleted.
    // solhint-disable-next-line ordering
    function deleteL2Outputs(uint256 _l2OutputIndex) external {
        require(systemConfig.isProposalManager(msg.sender), "L2OutputOracle: caller is not allowed to delete outputs");

        // Make sure we're not *increasing* the length of the array.
        require(
            _l2OutputIndex < l2Outputs.length, "L2OutputOracle: cannot delete outputs after the latest output index"
        );

        // Do not allow deleting any outputs that have already been finalized.
        require(
            block.timestamp - l2Outputs[_l2OutputIndex].timestamp < FINALIZATION_PERIOD_SECONDS,
            "L2OutputOracle: cannot delete outputs that have already been finalized"
        );

        uint256 prevNextL2OutputIndex = nextOutputIndex();

        // Use assembly to delete the array elements because Solidity doesn't allow it.
        assembly {
            sstore(l2Outputs.slot, _l2OutputIndex)
        }

        emit OutputsDeleted(prevNextL2OutputIndex, _l2OutputIndex);
    }

    /// @notice Accepts an outputRoot and the timestamp of the corresponding L2 block.
    ///         The timestamp must be equal to the current value returned by `nextTimestamp()` in
    ///         order to be accepted. This function may only be called by the Proposer.
    /// @param _outputRoot    The L2 output of the checkpoint block.
    /// @param _l2BlockNumber The L2 block number that resulted in _outputRoot.
    /// @param _l1BlockHash   A block hash which must be included in the current chain.
    /// @param _l1BlockNumber The block number with the specified block hash.
    function proposeL2Output(
        bytes32 _outputRoot,
        uint256 _l2BlockNumber,
        bytes32 _l1BlockHash,
        uint256 _l1BlockNumber
    )
        external
        payable
    {
        require(
            msg.sender == systemConfig.proposer(), "L2OutputOracle: only the proposer address can propose new outputs"
        );

        require(
            _l2BlockNumber == nextBlockNumber(),
            "L2OutputOracle: block number must be equal to next expected block number"
        );

        require(
            computeL2Timestamp(_l2BlockNumber) < block.timestamp,
            "L2OutputOracle: cannot propose L2 output in the future"
        );

        require(_outputRoot != bytes32(0), "L2OutputOracle: L2 output proposal cannot be the zero hash");

        if (_l1BlockHash != bytes32(0)) {
            // This check allows the proposer to propose an output based on a given L1 block,
            // without fear that it will be reorged out.
            // It will also revert if the blockheight provided is more than 256 blocks behind the
            // chain tip (as the hash will return as zero). This does open the door to a griefing
            // attack in which the proposer's submission is censored until the block is no longer
            // retrievable, if the proposer is experiencing this attack it can simply leave out the
            // blockhash value, and delay submission until it is confident that the L1 block is
            // finalized.
            require(
                blockhash(_l1BlockNumber) == _l1BlockHash,
                "L2OutputOracle: block hash does not match the hash at the expected height"
            );
        }

        emit OutputProposed(_outputRoot, nextOutputIndex(), _l2BlockNumber, block.timestamp);

        l2Outputs.push(
            Types.OutputProposal({
                outputRoot: _outputRoot,
                timestamp: uint128(block.timestamp),
                l2BlockNumber: uint128(_l2BlockNumber)
            })
        );
    }

    /// @notice Returns an output by index. Needed to return a struct instead of a tuple.
    /// @param _l2OutputIndex Index of the output to return.
    /// @return The output at the given index.
    function getL2Output(uint256 _l2OutputIndex) external view returns (Types.OutputProposal memory) {
        return l2Outputs[_l2OutputIndex];
    }

    /// @notice Returns the index of the L2 output that checkpoints a given L2 block number.
    ///         Uses a binary search to find the first output greater than or equal to the given
    ///         block.
    /// @param _l2BlockNumber L2 block number to find a checkpoint for.
    /// @return Index of the first checkpoint that commits to the given L2 block number.
    function getL2OutputIndexAfter(uint256 _l2BlockNumber) public view returns (uint256) {
        // Make sure an output for this block number has actually been proposed.
        require(
            _l2BlockNumber <= latestBlockNumber(),
            "L2OutputOracle: cannot get output for a block that has not been proposed"
        );

        // Make sure there's at least one output proposed.
        require(l2Outputs.length > 0, "L2OutputOracle: cannot get output as no outputs have been proposed yet");

        // Find the output via binary search, guaranteed to exist.
        uint256 lo = 0;
        uint256 hi = l2Outputs.length;
        while (lo < hi) {
            uint256 mid = (lo + hi) / 2;
            if (l2Outputs[mid].l2BlockNumber < _l2BlockNumber) {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }

        return lo;
    }

    /// @notice Returns the L2 output proposal that checkpoints a given L2 block number.
    ///         Uses a binary search to find the first output greater than or equal to the given
    ///         block.
    /// @param _l2BlockNumber L2 block number to find a checkpoint for.
    /// @return First checkpoint that commits to the given L2 block number.
    function getL2OutputAfter(uint256 _l2BlockNumber) external view returns (Types.OutputProposal memory) {
        return l2Outputs[getL2OutputIndexAfter(_l2BlockNumber)];
    }

    /// @notice Returns the number of outputs that have been proposed.
    ///         Will revert if no outputs have been proposed yet.
    /// @return The number of outputs that have been proposed.
    function latestOutputIndex() external view returns (uint256) {
        return l2Outputs.length - 1;
    }

    /// @notice Returns the index of the next output to be proposed.
    /// @return The index of the next output to be proposed.
    function nextOutputIndex() public view returns (uint256) {
        return l2Outputs.length;
    }

    /// @notice Returns the block number of the latest submitted L2 output proposal.
    ///         If no proposals been submitted yet then this function will return the starting
    ///         block number.
    /// @return Latest submitted L2 block number.
    function latestBlockNumber() public view returns (uint256) {
        return l2Outputs.length == 0 ? startingBlockNumber : l2Outputs[l2Outputs.length - 1].l2BlockNumber;
    }

    /// @notice Computes the block number of the next L2 block that needs to be checkpointed.
    /// @return Next L2 block number.
    function nextBlockNumber() public view returns (uint256) {
        return latestBlockNumber() + SUBMISSION_INTERVAL;
    }

    /// @notice Returns the L2 timestamp corresponding to a given L2 block number.
    /// @param _l2BlockNumber The L2 block number of the target block.
    /// @return L2 timestamp of the given block.
    function computeL2Timestamp(uint256 _l2BlockNumber) public view returns (uint256) {
        return startingTimestamp + ((_l2BlockNumber - startingBlockNumber) * L2_BLOCK_TIME);
    }
}
