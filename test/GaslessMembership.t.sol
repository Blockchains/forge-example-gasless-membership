// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {EntryPoint} from "@account-abstraction/contracts/core/EntryPoint.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "@account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {SimpleAccount} from "@account-abstraction/contracts/accounts/SimpleAccount.sol";
import {SimpleAccountFactory} from "@account-abstraction/contracts/accounts/SimpleAccountFactory.sol";
import {BaseAccount} from "@account-abstraction/contracts/core/BaseAccount.sol";
import {MembershipNFT} from "../src/MembershipNFT.sol";
import {ClubPaymaster} from "../src/ClubPaymaster.sol";

abstract contract GaslessBase is Test {
    IEntryPoint ep;
    SimpleAccountFactory factory;
    MembershipNFT club;
    ClubPaymaster paymaster;
    address admin = address(0xAD);
    uint256 memberKey = 0x5EC12E7;
    address payable bundler = payable(address(0xB0D1E5));

    function _deployApp() internal {
        factory = new SimpleAccountFactory(ep);
        club = new MembershipNFT(admin, "ipfs://club/");
        paymaster = new ClubPaymaster(ep, club, 0.05 ether, address(this));
        vm.deal(address(this), 10 ether);
        paymaster.deposit{value: 1 ether}();
    }

    function _joinOp(uint256 salt) internal view returns (PackedUserOperation memory op, address sender) {
        address owner = vm.addr(memberKey);
        sender = factory.getAddress(owner, salt);
        op.sender = sender;
        op.nonce = ep.getNonce(sender, 0);
        op.initCode = sender.code.length == 0 ? abi.encodePacked(address(factory), abi.encodeCall(SimpleAccountFactory.createAccount, (owner, salt))) : bytes("");
        op.callData = abi.encodeCall(BaseAccount.execute, (address(club), 0, abi.encodeCall(MembershipNFT.join, ())));
        op.accountGasLimits = bytes32((uint256(1_000_000) << 128) | uint256(300_000));
        op.preVerificationGas = 60_000;
        op.gasFees = bytes32((uint256(1 gwei) << 128) | uint256(2 gwei));
        op.paymasterAndData = abi.encodePacked(address(paymaster), uint128(200_000), uint128(50_000));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(memberKey, ep.getUserOpHash(op));
        op.signature = abi.encodePacked(r, s, v);
    }

    function _send(PackedUserOperation memory op) internal {
        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = op;
        vm.prank(bundler, bundler);
        ep.handleOps(ops, bundler);
    }

    function _approve(address a) internal {
        vm.prank(admin);
        club.setApproved(a, true);
    }
}

/// Runs against a fresh deployment of the real eth-infinitism v0.9.0 EntryPoint bytecode.
contract GaslessMembershipLocalTest is GaslessBase {
    function setUp() public {
        ep = IEntryPoint(address(new EntryPoint()));
        _deployApp();
    }

    function test_ApprovedMemberJoinsWithZeroEth() public {
        (, address sender) = _joinOp(0);
        _approve(sender);
        (PackedUserOperation memory op,) = _joinOp(0);
        uint256 dep = ep.balanceOf(address(paymaster));
        _send(op);
        assertTrue(club.isMember(sender));
        assertEq(club.ownerOf(1), sender);
        assertEq(club.tokenURI(1), "ipfs://club/1.json");
        assertEq(sender.balance, 0, "member never held ETH");
        assertLt(ep.balanceOf(address(paymaster)), dep, "club paid the gas");
    }

    function test_UnapprovedAccountIsNotSponsored() public {
        (PackedUserOperation memory op,) = _joinOp(1);
        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = op;
        vm.expectRevert(abi.encodeWithSelector(IEntryPoint.FailedOp.selector, 0, "AA34 signature error"));
        vm.prank(bundler, bundler);
        ep.handleOps(ops, bundler);
    }

    function test_SecondJoinIsNotSponsored() public {
        (, address sender) = _joinOp(2);
        _approve(sender);
        (PackedUserOperation memory op,) = _joinOp(2);
        _send(op);
        (op,) = _joinOp(2);
        PackedUserOperation[] memory ops = new PackedUserOperation[](1);
        ops[0] = op;
        vm.expectRevert(abi.encodeWithSelector(IEntryPoint.FailedOp.selector, 0, "AA34 signature error"));
        vm.prank(bundler, bundler);
        ep.handleOps(ops, bundler);
    }

    function test_PassIsNonTransferableByDefault() public {
        (, address sender) = _joinOp(3);
        _approve(sender);
        (PackedUserOperation memory op,) = _joinOp(3);
        _send(op);
        vm.prank(sender);
        vm.expectRevert(MembershipNFT.NonTransferable.selector);
        club.transferFrom(sender, address(0xCAFE), 1);
    }

    function test_OnlyApproverCanApprove() public {
        vm.expectRevert();
        club.setApproved(address(0x1234), true);
    }
}

/// Same flow on a Sepolia fork against the canonical, already-deployed v0.9 EntryPoint.
contract GaslessMembershipSepoliaForkTest is GaslessBase {
    address constant CANONICAL_EP_V09 = 0x433709009B8330FDa32311DF1C2AFA402eD8D009;

    function setUp() public {
        vm.createSelectFork(vm.envOr("SEPOLIA_RPC_URL", string("https://ethereum-sepolia-rpc.publicnode.com")));
        ep = IEntryPoint(CANONICAL_EP_V09);
        _deployApp();
    }

    function test_Fork_JoinViaCanonicalEntryPoint() public {
        assertGt(CANONICAL_EP_V09.code.length, 0);
        (, address sender) = _joinOp(42);
        _approve(sender);
        (PackedUserOperation memory op,) = _joinOp(42);
        _send(op);
        assertTrue(club.isMember(sender));
        assertEq(sender.balance, 0);
    }
}
