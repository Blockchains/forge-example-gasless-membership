// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {IEntryPoint} from "@account-abstraction/contracts/interfaces/IEntryPoint.sol";
import {SimpleAccountFactory} from "@account-abstraction/contracts/accounts/SimpleAccountFactory.sol";
import {MembershipNFT} from "../src/MembershipNFT.sol";
import {ClubPaymaster} from "../src/ClubPaymaster.sol";

/// forge script script/Deploy.s.sol --rpc-url sepolia --account deployer --broadcast
/// Uses the canonical ERC-4337 v0.9 EntryPoint unless ENTRYPOINT is set.
contract Deploy is Script {
    function run() external {
        IEntryPoint ep = IEntryPoint(vm.envOr("ENTRYPOINT", address(0x433709009B8330FDa32311DF1C2AFA402eD8D009)));
        vm.startBroadcast();
        address admin = msg.sender;
        SimpleAccountFactory factory = new SimpleAccountFactory(ep);
        MembershipNFT club = new MembershipNFT(admin, vm.envOr("BASE_URI", string("ipfs://club/")));
        ClubPaymaster pm = new ClubPaymaster(ep, club, 0.005 ether, admin);
        pm.deposit{value: vm.envOr("PAYMASTER_DEPOSIT", uint256(0.01 ether))}();
        vm.stopBroadcast();
        console.log("SimpleAccountFactory", address(factory));
        console.log("MembershipNFT", address(club));
        console.log("ClubPaymaster", address(pm));
    }
}
