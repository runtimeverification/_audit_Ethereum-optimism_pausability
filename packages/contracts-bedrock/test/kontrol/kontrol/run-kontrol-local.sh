#!/bin/bash

set -euxo pipefail

export FOUNDRY_PROFILE=stategen # kontrol # hardcoded

# Create a log file to store standard out and standard error
LOG_FILE="run-kontrol-$(date +'%Y-%m-%d-%H-%M-%S').log"
exec > >(tee -i $LOG_FILE)
exec 2>&1

kontrol_build() {
    kontrol build                     \
            --verbose                 \
            --require ${lemmas}       \
            --module-import ${module} \
            ${regen}                  \
            ${rekompile}
}
  # --bmc-depth ${bmc_depth}           \
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
            ${use_booster} # \
             # --kore-rpc-command="kore-rpc-booster -l Rewrite"
}

###
# kontrol build options
###
# NOTE: This script should be executed from the `contracts-bedrock` directory
lemmas=test/kontrol/kontrol/pausability-lemmas.k
base_module=PAUSABILITY-LEMMAS
module=StateDiffTest:${base_module}

rekompile=--rekompile
regen=--regen
rekompile=
regen=

###
# kontrol prove options
###
max_depth=10000000

max_iterations=10000000

smt_timeout=100000

# bmc_depth=10

workers=1

reinit=--reinit
reinit=

break_on_calls=--no-break-on-calls
# break_on_calls=

auto_abstract=--auto-abstract-gas
# auto_abstract=

bug_report=--bug-report
bug_report=

use_booster=--use-booster
# use_booster=

# List of tests to symbolically execute
tests=""
#tests+="--match-test CounterTest.test_SetNumber "
#tests+="--match-test StateDiffTest.setUp "
# tests+="--match-test StateDiffCheatcode.recreateDeployment "
tests+="--match-test StateDiffTest.testConcrete "
tests+="--match-test StateDiffTest.testConcrete1 "
tests+="--match-test StateDiffTest.testConcrete2 "
tests+="--match-test StateDiffTest.testFailConcrete3 "
tests+="--match-test StateDiffTest.testConcrete4 "
tests+="--match-test StateDiffTest.testConcrete5 "
tests+="--match-test StateDiffTest.testConcrete6 "
# tests+="--match-test HardcodedDeployment.test_runHarcodedDeployment "

kontrol_build
kontrol_prove
