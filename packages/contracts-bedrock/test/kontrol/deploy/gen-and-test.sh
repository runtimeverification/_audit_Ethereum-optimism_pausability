#!/bin/bash

# This script shall be run from the `packages/contracts-bedrock` folder
set -euxo pipefail

export FOUNDRY_PROFILE=kontrol
STATEDIFF=snapshots/state-diff/Deploy.json
mkdir -p snapshots/state-diff
HARDHAT=deployments/hardhat/.deploy
HARDHAT_REVERSED=$HARDHAT-reversed
# This command updates the file deployments/hardhat/.deploy and snapshots/state-diff/statediff.json
forge script --target-contract OptimismDeploy test/kontrol/OptimismDeploy.s.sol
python3 test/kontrol/scripts/clean_json.py $STATEDIFF
cat $STATEDIFF | jq '.' > tmp.json
mv tmp.json $STATEDIFF
python3 test/kontrol/scripts/reverse_key_value.py  $HARDHAT $HARDHAT_REVERSED
python3 test/kontrol/scripts/generate_cheatcode.py DeployCheatcode $HARDHAT_REVERSED $STATEDIFF > test/kontrol/DeployCheatcode.sol
forge fmt
forge test --match-contract OptimismDeployCheatcodeTest --match-test "test_" -vvv