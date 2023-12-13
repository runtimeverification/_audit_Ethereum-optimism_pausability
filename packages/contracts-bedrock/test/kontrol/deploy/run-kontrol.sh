#!/bin/bash

set -euxo pipefail

export FOUNDRY_PROFILE=deploy

# Create a log file to store standard out and standard error
LOG_FILE="run-kontrol-$(date +'%Y-%m-%d-%H-%M-%S').log"
exec > >(tee -i $LOG_FILE)
exec 2>&1

kontrol_build() {
    kontrol build                     \
            --verbose                 \
            --require ${lemmas}       \
            --module-import ${module} \
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
lemmas=test/kontrol/kontrol/pausability-lemmas.k
base_module=PAUSABILITY-LEMMAS
module=OptimismPortalTest:${base_module}

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
tests+="--match-test OptimismPortalTest.test_finalize "
tests+="--match-test OptimismPortalTest.test_prove "

kontrol_build
kontrol_prove