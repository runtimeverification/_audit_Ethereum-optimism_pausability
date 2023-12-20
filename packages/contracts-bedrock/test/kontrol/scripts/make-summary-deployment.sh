set -euo pipefail

# create deployments/hardhat/.deploy and snapshots/state-diff/Deploy.json if necessary
if [ ! -d "deployments/hardhat" ]; then
  mkdir deployments/hardhat;
fi
if [ ! -f "deployments/hardhat/.deploy" ]; then
  touch deployments/hardhat/.deploy;
fi
if [ ! -d "snapshots/state-diff" ]; then
  mkdir snapshots/state-diff;
fi
if [ ! -f "snapshots/state-diff/Deploy.json" ]; then
  touch snapshots/state-diff/Deploy.json;
fi

DEPLOY_SCRIPT="./scripts/Deploy.s.sol"

# Create a backup
cp ${DEPLOY_SCRIPT} ${DEPLOY_SCRIPT}.bak

# replace mustGetAddress by getAddress in Deploy.s.sol
awk '{gsub(/mustGetAddress/, "getAddress")}1' ${DEPLOY_SCRIPT} > temp && mv temp ${DEPLOY_SCRIPT}

FOUNDRY_PROFILE=kdeploy forge script -vvv test/kontrol/KontrolDeployment.sol:KontrolDeployment --sig 'runKontrolDeployment()'
echo "Created state diff json"

# Restore the file from the backup
cp ${DEPLOY_SCRIPT}.bak ${DEPLOY_SCRIPT}
rm ${DEPLOY_SCRIPT}.bak

# Clean and store the state diff json in snapshots/state-diff/Kontrol-Deploy.json
JSON_SCRIPTS=test/kontrol/scripts/json
GENERATED_STATEDIFF=Deploy.json # Name of the statediff json produced by the deployment script
STATEDIFF=Kontrol-${GENERATED_STATEDIFF} # Name of the Kontrol statediff
mv snapshots/state-diff/${GENERATED_STATEDIFF} snapshots/state-diff/${STATEDIFF}
python3 ${JSON_SCRIPTS}/clean_json.py snapshots/state-diff/${STATEDIFF}
echo "Cleaned state diff json"

CONTRACT_NAMES=deployments/hardhat/.deploy
python3 ${JSON_SCRIPTS}/reverse_key_values.py ${CONTRACT_NAMES} ${CONTRACT_NAMES}Reversed
CONTRACT_NAMES=${CONTRACT_NAMES}Reversed

PROOFS_DIR=test/kontrol/proofs
SUMMARY_NAME=DeploymentSummary
kontrol summary ${SUMMARY_NAME} snapshots/state-diff/${STATEDIFF} --contract-names ${CONTRACT_NAMES} --output-dir ${PROOFS_DIR}
echo "Added state updates to ${PROOFS_DIR}/${SUMMARY_NAME}.sol"
