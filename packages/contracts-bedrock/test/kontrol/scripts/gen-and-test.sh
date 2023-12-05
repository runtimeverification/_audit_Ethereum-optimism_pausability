#!/bin/bash

# This script shall be run from the `packages/contracts-bedrock` folder
set -euxo pipefail

export FOUNDRY_PROFILE=kontrol
STATEDIFF=snapshots/state-diff/statediff.json
HARDHAT=deployments/hardhat/.deploy
HARDHAT_REVERSED=$HARDHAT-reversed
# This command updates the file deployments/hardhat/.deploy and snapshots/state-diff/statediff.json
forge test --match-contract OptimismPortalTest2 --match-test "test_finalize()"
python3 test/kontrol/scripts/clean_json.py $STATEDIFF
python3 test/kontrol/scripts/reverse_key_value.py  $HARDHAT $HARDHAT_REVERSED
python3 test/kontrol/scripts/generate_cheatcode.py SetupCheatcode $HARDHAT_REVERSED $STATEDIFF > test/kontrol/SetupCheatcode.sol
forge test --match-contract OptimismPortalTest3 --match-test "test_finalize()" -vvv
