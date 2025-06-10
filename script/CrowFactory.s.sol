// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {CrowFactory} from "../src/CrowFactory.sol";

contract CrowFactoryScript is Script {
    CrowFactory public crow;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        crow = new CrowFactory();

        vm.stopBroadcast();
    }
}
