#!/bin/bash

set -euxo pipefail

export FOUNDRY_PROFILE=kontrol

# Create a log file to store standard out and standard error
LOG_FILE="run-kontrol-$(date +'%Y-%m-%d-%H-%M-%S').log"
exec > >(tee -i $LOG_FILE)
exec 2>&1

kontrol_generateCheatcode() {
    STATEDIFF=snapshots/state-diff/Deploy.json
    mkdir -p snapshots/state-diff
    HARDHAT=deployments/hardhat/.deploy
    CONTRACT_NAMES=$HARDHAT-reversed
    # This command updates the file deployments/hardhat/.deploy and snapshots/state-diff/Deploy.json
    forge script --target-contract OptimismDeploy --sig 'deployL1()' kontrol/script/OptimismDeploy.s.sol --skip test
    python3 kontrol/utils/clean_json.py $STATEDIFF
    python3 kontrol/utils/reverse_key_value.py  $HARDHAT $CONTRACT_NAMES
    kontrol summary DeploymentSummary $STATEDIFF --contract-names $CONTRACT_NAMES --output-dir kontrol/src
    forge test --match-contract OptimismDeployTest --match-test "test_" -vvv
    rm -rf snapshots/state-diff
}

kontrol_build() {
    kontrol build                     \
            --verbose                 \
            --require ${lemmas}       \
            ${module}                 \
            ${rekompile}
}

kontrol_prove() {
    kontrol prove                              \
            --verbose                          \
            --max-depth ${max_depth}           \
            --max-iterations ${max_iterations} \
            --smt-timeout ${smt_timeout}       \
            --workers ${workers}               \
            ${reinit}                          \
            ${bug_report}                      \
            ${break_on_calls}                  \
            ${auto_abstract}                   \
            ${tests}                           \
            ${use_booster}
}

###
# kontrol build options
###
# NOTE: This script should be executed from the `contracts-bedrock` directory
lemmas=kontrol/lemmas/pausability-lemmas.k
base_module=PAUSABILITY-LEMMAS
module=""
module+="--module-import OptimismPortalTest:${base_module} "
module+="--module-import L1CrossDomainMessengerTest:${base_module} "

rekompile=--rekompile
rekompile=

###
# kontrol prove options
###
max_depth=100000000

max_iterations=10000000

smt_timeout=10000000

bmc_depth=10

workers=1

reinit=--reinit
reinit=

break_on_calls=--no-break-on-calls
# break_on_calls=

auto_abstract=--auto-abstract-gas
# auto_abstract=

bug_report="--bug-report SetupBugReport "
# bug_report=

use_booster=--use-booster
# use_booster=

# List of tests to symbolically execute
tests=""
tests+="--match-test OptimismPortalTest.test_finalizeWithdrawalTransaction "
tests+="--match-test OptimismPortalTest.test_proveWithdrawalTransaction "
tests+="--match-test L1CrossDomainMessengerTest.test_relayMessage "

kontrol_generateCheatcode
kontrol_build
kontrol_prove
