#!/bin/bash

set -euxo pipefail

export FOUNDRY_PROFILE=kontrol
# This command updates the file deployments/hardhat/.deploy and snapshots/state-diff/statediff.json
forge test --match-contract OptimismPortalTest2 --match-test "test_finalize()"
python3 clean_json.py snapshots/state-diff/statediff.json
python3 reverse_key_value.py deployments/hardhat/.deploy deployments/hardhat/.deploy-reversed
python3 generate_cheatcode.py SetupCheatcode deployments/hardhat/.deploy-reversed snapshots/state-diff/statediff.json > test/kontrol/SetupCheatcode.sol
forge test --match-contract OptimismPortalTest3 --match-test "test_finalize()" -vvv
