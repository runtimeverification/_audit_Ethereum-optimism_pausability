// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import { Deploy } from "scripts/Deploy.s.sol";

contract OptimismDeploy is Deploy {
    /// @dev Sets up the L1 contracts.
    function runFullL1Deployment() external {
        super.setUp();

        vm.fee(1 gwei);
        vm.warp(cfg.l2OutputOracleStartingTimestamp() + 1);
        vm.roll(cfg.l2OutputOracleStartingBlockNumber() + 1);
        // Set the deterministic deployer in state to ensure that it is there
        vm.etch(
            0x4e59b44847b379578588920cA78FbF26c0B4956C,
            hex"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe03601600081602082378035828234f58015156039578182fd5b8082525050506014600cf3"
        );

        runWithStateDiff();
    }

    function runKontrolDeployment() public stateDiff {
        deploySafe();
        setupSuperchain();

        // all proxies need to be deplpoyed as the proxies addresses are accessed when initializing each implementation (below);
        deployProxies();

        /* deployImplementations(); */
        deployOptimismPortal();
        deployL2OutputOracle();
        deployL1CrossDomainMessenger();
        deploySystemConfig();

        /* initializeImplementations(); */
        initializeSystemConfig();
        initializeL1CrossDomainMessenger();
        initializeOptimismPortal();
    }
}
