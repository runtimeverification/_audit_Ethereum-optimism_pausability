#Env vars
export ETH_RPC_URL=http://localhost:8545 #127.0.0.1:8545
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 # First anvil private key
export ETH_RPC_URL=
export PRIVATE_KEY=

# forge script -vvvvv test/kontrol/StateDiff.sol:MakeStateDiff --sig 'testStateDiff()' --broadcast # --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY
forge script -vvv scripts/Deploy.s.sol:Deploy --sig 'runWithStateDiff()' # --rpc-url $ETH_RPC_URL --private-key $PRIVATE_KEY
echo "Created state diff json"

#STATEDIFF=TestDiff.json
STATEDIFF=Deploy.json
python3 test/kontrol/scripts/clean_json.py snapshots/state-diff/${STATEDIFF}
echo "Cleaned state diff json"

#CONTRACT_NAMES='CounterNames.json'

# Clean json produced by Deployer.s.sol::runWithStateDiff()
CONTRACT_NAMES=deployments/hardhat/.deploy
python3 test/kontrol/scripts/reverse_key_value.py ${CONTRACT_NAMES} ${CONTRACT_NAMES}Reversed
CONTRACT_NAMES=${CONTRACT_NAMES}Reversed

STATEDIFF_CONTRACT=test/kontrol/StateDiffCheatcode.sol
python3 test/kontrol/scripts/generate_cheatcode.py StateDiffCheatcode ${CONTRACT_NAMES} snapshots/state-diff/${STATEDIFF} > ${STATEDIFF_CONTRACT}
echo "Added State Updates to ${STATEDIFF_CONTRACT}"