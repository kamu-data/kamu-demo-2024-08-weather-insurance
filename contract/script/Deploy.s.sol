// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {InsuranceBroker} from "../src/InsuranceBroker.sol";

import {OdfOracle} from "@opendatafabric/contracts/src/OdfOracle.sol";

import {BaseScript} from "./Base.s.sol";

contract Deploy is BaseScript {
    function run() public broadcast {
        OdfOracle oracle = OdfOracle(vm.envAddress("ORACLE_CONTRACT_ADDR"));
        new InsuranceBroker(address(oracle));
    }
}
