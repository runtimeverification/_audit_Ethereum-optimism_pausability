#!/bin/bash

set -euxo pipefail

export FOUNDRY_PROFILE=kontrol

# Create a log file to store standard out and standard error
LOG_FILE="test/kontrol/kontrol/logs/kontrol-$(date +'%Y-%m-%d-%H-%M-%S').log"
exec > >(tee -i $LOG_FILE)
exec 2>&1

forge_build() {
  forge build --root . --skip scripts
}

kontrol_build() {
    kontrol build                     \
            --verbose                 \
            ${no_forge_build}         \
            --require ${lemmas}       \
            --module-import ${module} \
            ${rekompile}              \
            ${regen}
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
            ${use_booster}                     \
            # --bmc-depth ${bmc_depth}
}

###
# kontrol build options
###
# NOTE: This script should be executed from the `contracts-bedrock` directory
lemmas=test/kontrol/kontrol/pausability-lemmas.k
base_module=PAUSABILITY-LEMMAS
module=OptimismPortalKontrol:${base_module}

rekompile=--rekompile
regen=--regen
# rekompile=
# regen=

no_forge_build=--no-forge-build
# no_forge_build=

###
# kontrol prove options
###
max_depth=10000

max_iterations=10000

smt_timeout=100000

# bmc_depth=10

workers=2

reinit=--reinit
#reinit=

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
# tests+="--match-test OptimismPortalKontrol.test_bytes(uint256):0 "
tests+="--match-test OptimismPortalKontrol.test_proveWithdrawalTransaction_paused "

forge_build
kontrol_build
kontrol_prove
