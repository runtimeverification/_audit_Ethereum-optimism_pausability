// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "src/libraries/DisputeTypes.sol";
import "src/libraries/DisputeErrors.sol";

import { Test } from "forge-std/Test.sol";
import { DisputeGameFactory } from "src/dispute/DisputeGameFactory.sol";
import { IDisputeGame } from "src/dispute/interfaces/IDisputeGame.sol";
import { Proxy } from "src/universal/Proxy.sol";
import { CommonTest } from "test/setup/CommonTest.sol";

contract DisputeGameFactory_Init is CommonTest {
    DisputeGameFactory factory;
    FakeClone fakeClone;

    event DisputeGameCreated(address indexed disputeProxy, GameType indexed gameType, Claim indexed rootClaim);
    event ImplementationSet(address indexed impl, GameType indexed gameType);
    event InitBondUpdated(GameType indexed gameType, uint256 indexed newBond);

    function setUp() public virtual override {
        super.setUp();

        Proxy proxy = new Proxy(address(this));
        DisputeGameFactory impl = new DisputeGameFactory();

        proxy.upgradeToAndCall({
            _implementation: address(impl),
            _data: abi.encodeCall(impl.initialize, (address(this)))
        });
        factory = DisputeGameFactory(address(proxy));
        vm.label(address(factory), "DisputeGameFactoryProxy");

        fakeClone = new FakeClone();
    }
}

contract DisputeGameFactory_Create_Test is DisputeGameFactory_Init {
    /// @dev Tests that the `create` function succeeds when creating a new dispute game
    ///      with a `GameType` that has an implementation set.
    function testFuzz_create_succeeds(
        uint8 gameType,
        Claim rootClaim,
        bytes calldata extraData,
        uint256 _value
    )
        public
    {
        // Ensure that the `gameType` is within the bounds of the `GameType` enum's possible values.
        GameType gt = GameType.wrap(uint8(bound(gameType, 0, 2)));
        // Ensure the rootClaim has a VMStatus that disagrees with the validity.
        rootClaim = changeClaimStatus(rootClaim, VMStatuses.INVALID);

        // Set all three implementations to the same `FakeClone` contract.
        for (uint8 i; i < 3; i++) {
            GameType lgt = GameType.wrap(i);
            factory.setImplementation(lgt, IDisputeGame(address(fakeClone)));
            factory.setInitBond(lgt, _value);
        }

        vm.deal(address(this), _value);

        vm.expectEmit(false, true, true, false);
        emit DisputeGameCreated(address(0), gt, rootClaim);
        IDisputeGame proxy = factory.create{ value: _value }(gt, rootClaim, extraData);

        (IDisputeGame game, Timestamp timestamp) = factory.games(gt, rootClaim, extraData);

        // Ensure that the dispute game was assigned to the `disputeGames` mapping.
        assertEq(address(game), address(proxy));
        assertEq(Timestamp.unwrap(timestamp), block.timestamp);
        assertEq(factory.gameCount(), 1);

        (, Timestamp timestamp2, IDisputeGame game2) = factory.gameAtIndex(0);
        assertEq(address(game2), address(proxy));
        assertEq(Timestamp.unwrap(timestamp2), block.timestamp);

        // Ensure that the game proxy received the bonded ETH.
        assertEq(address(proxy).balance, _value);
    }

    /// @dev Tests that the `create` function reverts when creating a new dispute game with an insufficient bond.
    function testFuzz_create_insufficientBond_reverts(
        uint8 gameType,
        Claim rootClaim,
        bytes calldata extraData
    )
        public
    {
        // Ensure that the `gameType` is within the bounds of the `GameType` enum's possible values.
        GameType gt = GameType.wrap(uint8(bound(gameType, 0, 2)));
        // Ensure the rootClaim has a VMStatus that disagrees with the validity.
        rootClaim = changeClaimStatus(rootClaim, VMStatuses.INVALID);

        // Set all three implementations to the same `FakeClone` contract.
        for (uint8 i; i < 3; i++) {
            GameType lgt = GameType.wrap(i);
            factory.setImplementation(lgt, IDisputeGame(address(fakeClone)));
            factory.setInitBond(lgt, 1 ether);
        }

        vm.expectRevert(InsufficientBond.selector);
        factory.create(gt, rootClaim, extraData);
    }

    /// @dev Tests that the `create` function reverts when there is no implementation
    ///      set for the given `GameType`.
    function testFuzz_create_noImpl_reverts(uint8 gameType, Claim rootClaim, bytes calldata extraData) public {
        // Ensure that the `gameType` is within the bounds of the `GameType` enum's possible values.
        GameType gt = GameType.wrap(uint8(bound(gameType, 0, 2)));
        // Ensure the rootClaim has a VMStatus that disagrees with the validity.
        rootClaim = changeClaimStatus(rootClaim, VMStatuses.INVALID);

        vm.expectRevert(abi.encodeWithSelector(NoImplementation.selector, gt));
        factory.create(gt, rootClaim, extraData);
    }

    /// @dev Tests that the `create` function reverts when there exists a dispute game with the same UUID.
    function testFuzz_create_sameUUID_reverts(uint8 gameType, Claim rootClaim, bytes calldata extraData) public {
        // Ensure that the `gameType` is within the bounds of the `GameType` enum's possible values.
        GameType gt = GameType.wrap(uint8(bound(gameType, 0, 2)));
        // Ensure the rootClaim has a VMStatus that disagrees with the validity.
        rootClaim = changeClaimStatus(rootClaim, VMStatuses.INVALID);

        // Set all three implementations to the same `FakeClone` contract.
        for (uint8 i; i < 3; i++) {
            factory.setImplementation(GameType.wrap(i), IDisputeGame(address(fakeClone)));
        }

        // Create our first dispute game - this should succeed.
        vm.expectEmit(false, true, true, false);
        emit DisputeGameCreated(address(0), gt, rootClaim);
        IDisputeGame proxy = factory.create(gt, rootClaim, extraData);

        (IDisputeGame game, Timestamp timestamp) = factory.games(gt, rootClaim, extraData);
        // Ensure that the dispute game was assigned to the `disputeGames` mapping.
        assertEq(address(game), address(proxy));
        assertEq(Timestamp.unwrap(timestamp), block.timestamp);

        // Ensure that the `create` function reverts when called with parameters that would result in the same UUID.
        vm.expectRevert(
            abi.encodeWithSelector(GameAlreadyExists.selector, factory.getGameUUID(gt, rootClaim, extraData))
        );
        factory.create(gt, rootClaim, extraData);
    }

    function changeClaimStatus(Claim _claim, VMStatus _status) public pure returns (Claim out_) {
        assembly {
            out_ := or(and(not(shl(248, 0xFF)), _claim), shl(248, _status))
        }
    }
}

contract DisputeGameFactory_SetImplementation_Test is DisputeGameFactory_Init {
    /// @dev Tests that the `setImplementation` function properly sets the implementation for a given `GameType`.
    function test_setImplementation_succeeds() public {
        // There should be no implementation for the `GameTypes.CANNON` enum value, it has not been set.
        assertEq(address(factory.gameImpls(GameTypes.CANNON)), address(0));

        vm.expectEmit(true, true, true, true, address(factory));
        emit ImplementationSet(address(1), GameTypes.CANNON);

        // Set the implementation for the `GameTypes.CANNON` enum value.
        factory.setImplementation(GameTypes.CANNON, IDisputeGame(address(1)));

        // Ensure that the implementation for the `GameTypes.CANNON` enum value is set.
        assertEq(address(factory.gameImpls(GameTypes.CANNON)), address(1));
    }

    /// @dev Tests that the `setImplementation` function reverts when called by a non-owner.
    function test_setImplementation_notOwner_reverts() public {
        // Ensure that the `setImplementation` function reverts when called by a non-owner.
        vm.prank(address(0));
        vm.expectRevert("Ownable: caller is not the owner");
        factory.setImplementation(GameTypes.CANNON, IDisputeGame(address(1)));
    }
}

contract DisputeGameFactory_SetInitBond_Test is DisputeGameFactory_Init {
    /// @dev Tests that the `setInitBond` function properly sets the init bond for a given `GameType`.
    function test_setInitBond_succeeds() public {
        // There should be no init bond for the `GameTypes.CANNON` enum value, it has not been set.
        assertEq(factory.initBonds(GameTypes.CANNON), 0);

        vm.expectEmit(true, true, true, true, address(factory));
        emit InitBondUpdated(GameTypes.CANNON, 1 ether);

        // Set the init bond for the `GameTypes.CANNON` enum value.
        factory.setInitBond(GameTypes.CANNON, 1 ether);

        // Ensure that the init bond for the `GameTypes.CANNON` enum value is set.
        assertEq(factory.initBonds(GameTypes.CANNON), 1 ether);
    }

    /// @dev Tests that the `setInitBond` function reverts when called by a non-owner.
    function test_setInitBond_notOwner_reverts() public {
        // Ensure that the `setInitBond` function reverts when called by a non-owner.
        vm.prank(address(0));
        vm.expectRevert("Ownable: caller is not the owner");
        factory.setInitBond(GameTypes.CANNON, 1 ether);
    }
}

contract DisputeGameFactory_GetGameUUID_Test is DisputeGameFactory_Init {
    /// @dev Tests that the `getGameUUID` function returns the correct hash when comparing
    ///      against the keccak256 hash of the abi-encoded parameters.
    function testDiff_getGameUUID_succeeds(uint8 gameType, Claim rootClaim, bytes calldata extraData) public {
        // Ensure that the `gameType` is within the bounds of the `GameType` enum's possible values.
        GameType gt = GameType.wrap(uint8(bound(gameType, 0, 2)));

        assertEq(
            Hash.unwrap(factory.getGameUUID(gt, rootClaim, extraData)), keccak256(abi.encode(gt, rootClaim, extraData))
        );
    }
}

contract DisputeGameFactory_Owner_Test is DisputeGameFactory_Init {
    /// @dev Tests that the `owner` function returns the correct address after deployment.
    function test_owner_succeeds() public {
        assertEq(factory.owner(), address(this));
    }
}

contract DisputeGameFactory_TransferOwnership_Test is DisputeGameFactory_Init {
    /// @dev Tests that the `transferOwnership` function succeeds when called by the owner.
    function test_transferOwnership_succeeds() public {
        factory.transferOwnership(address(1));
        assertEq(factory.owner(), address(1));
    }

    /// @dev Tests that the `transferOwnership` function reverts when called by a non-owner.
    function test_transferOwnership_notOwner_reverts() public {
        vm.prank(address(0));
        vm.expectRevert("Ownable: caller is not the owner");
        factory.transferOwnership(address(1));
    }
}

/// @dev A fake clone used for testing the `DisputeGameFactory` contract's `create` function.
contract FakeClone {
    function initialize() external payable {
        // noop
    }
}
