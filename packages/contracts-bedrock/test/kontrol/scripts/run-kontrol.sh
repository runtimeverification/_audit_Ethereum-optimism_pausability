#!/bin/bash
set -euo pipefail

export FOUNDRY_PROFILE=kprove

# Set Script Context Variables
SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
RESULTS_FILE="results-$(date +'%Y-%m-%d-%H-%M-%S').tar.gz"
LOG_PATH="$SCRIPT_HOME/logs"
RESULTS_KOUT="$LOG_PATH/$RESULTS_FILE"
if [ ! -d $LOG_PATH ]; then
  mkdir -p $LOG_PATH
fi

# shellcheck source=/dev/null
source "$SCRIPT_HOME/common.sh"
export RUN_KONTROL=true
parse_args "$@"

# Set up trap to run clean-up and logging on failure
trap on_failure ERR INT

#########################
# kontrol build options #
#########################
# NOTE: This script has a recurring pattern of setting and unsetting variables,
# such as `rekompile`. Such a pattern is intended for easy use while locally
# developing and executing the proofs via this script. Comment/uncomment the
# empty assignment to activate/deactivate the corresponding flag
lemmas=test/kontrol/pausability-lemmas.md
base_module=PAUSABILITY-LEMMAS
module=OptimismPortalKontrol:$base_module
rekompile=--rekompile
rekompile=
regen=--regen
# shellcheck disable=SC2034
regen=

#################################
# Tests to symbolically execute #
#################################

# Temporarily unexecuted tests
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused0" \
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused1" \
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused2" \
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused3" \
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused4" \
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused5" \
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused6" \
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused7" \
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused8" \
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused9" \
# "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused10" \

test_list=()
if [ "$SCRIPT_TESTS" == true ]; then
  test_list=( "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused0" \
              "OptimismPortalKontrol.prove_proveWithdrawalTransaction_paused1" \
              "OptimismPortalKontrol.prove_finalizeWithdrawalTransaction_paused" \
              "L1StandardBridgeKontrol.prove_finalizeBridgeERC20_paused" \
              "L1StandardBridgeKontrol.prove_finalizeBridgeETH_paused" \
              "L1ERC721BridgeKontrol.prove_finalizeBridgeERC721_paused" \
              "L1CrossDomainMessengerKontrol.prove_relayMessage_paused"
  )
elif [ "$CUSTOM_TESTS" != 0 ]; then
  test_list=( "${@:${CUSTOM_TESTS}}" )
fi
tests=""
for test_name in "${test_list[@]}"; do
  tests+="--match-test $test_name "
done

#########################
# kontrol prove options #
#########################
max_depth=10000
max_iterations=10000
smt_timeout=100000
max_workers=7 # Set to 7 since the CI machine has 8 CPUs
# workers is the minimum between max_workers and the length of test_list
# unless no test arguments are provided, in which case we default to max_workers
if [ "$CUSTOM_TESTS" == 0 ] && [ "$SCRIPT_TESTS" == false ]; then
  workers=${max_workers}
else
  workers=$((${#test_list[@]}>max_workers ? max_workers : ${#test_list[@]}))
fi
reinit=--reinit
reinit=
break_on_calls=--no-break-on-calls
# break_on_calls=
break_every_step=--break-every-step
break_every_step=
auto_abstract=--auto-abstract-gas
auto_abstract=
bug_report=--bug-report
bug_report=
use_booster=--use-booster
# use_booster=
state_diff="./snapshots/state-diff/Kontrol-Deploy.json"

#############
# RUN TESTS #
#############
conditionally_start_docker

kontrol_build
kontrol_prove

dump_log_results

if [ "$LOCAL" == false ]; then
    notif "Stopping docker container"
    clean_docker
fi

notif "DONE"
