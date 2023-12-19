#!/bin/bash

set -euxo pipefail

export FOUNDRY_PROFILE=kprove

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

#########################
# kontrol build options #
#########################
# NOTE: This script has a recurring pattern of setting and unsetting variables,
# such as `rekompile`. Such a pattern is intended for easy use while locally
# developing and executing the proofs via this script. Comment/uncomment the
# empty assignment to activate/deactivate the corresponding flag
lemmas=test/kontrol/kontrol/pausability-lemmas.k
base_module=PAUSABILITY-LEMMAS
module=Workarounds:${base_module}

rekompile=--rekompile
regen=--regen
# rekompile=
# regen=

#########################
# kontrol prove options #
#########################
max_depth=10000000
max_iterations=10000000
smt_timeout=100000
workers=3
reinit=--reinit
# reinit=
break_on_calls=--no-break-on-calls
# break_on_calls=
auto_abstract=--auto-abstract-gas
# auto_abstract=
bug_report=--bug-report
bug_report=
use_booster=--use-booster
# use_booster=

#########################################
# List of tests to symbolically execute #
#########################################
tests=""
# tests+="--match-test OptimismPortalKontrol.test_proveWithdrawalTransaction_calldata "
# tests+="--match-test OptimismPortalKontrol.test_finalizeWithdrawalTransaction_paused "
tests+="--match-test Workarounds.test_workaround1 "
tests+="--match-test Workarounds.test_workaround2 "
tests+="--match-test Workarounds.test_workaround3 "

kontrol_build
kontrol_prove
