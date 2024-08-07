// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test} from "forge-std/src/Test.sol";
// import { console2 } from "forge-std/src/console2.sol";

import {InsuranceBroker} from "../src/InsuranceBroker.sol";
import {OdfResponse} from "@opendatafabric/contracts/src/Odf.sol";
import {OdfOracle} from "@opendatafabric/contracts/src/OdfOracle.sol";

contract InsuranceBrokerTest is Test {
    OdfOracle internal oracle;
    InsuranceBroker internal broker;

    function setUp() public virtual {
        oracle = new OdfOracle({logConsumerErrorData: false});
        broker = new InsuranceBroker(address(oracle));
    }

    function testHappyPathInsurerFavor() public {
        address holder = vm.addr(1);
        address insurer = vm.addr(2);
        address provider = vm.addr(3);

        // Holder applies
        deal(holder, 1 ether);
        vm.prank(holder);
        vm.expectEmit(true, true, true, true);
        emit InsuranceBroker.CoverageApplication(1, holder, 1 ether);
        uint64 policyId = broker.applyForCoverage{value: 1 ether}(
            100,
            "did:odf:fed01553538ac45d78e8e7879efb166e592b287f539dd7a0cf5b4d9df8f3fa8a7a899"
        );
        assertEq(holder.balance, 0 ether);

        // Insurer bids
        deal(insurer, 100 ether);
        vm.prank(insurer);
        vm.expectEmit(true, true, true, true);
        emit InsuranceBroker.PolicyCreated(
            1,
            holder,
            insurer,
            1 ether,
            100 ether
        );
        broker.bidForCoverage{value: 100 ether}(policyId);
        assertEq(insurer.balance, 0 ether);
        assertEq(address(broker).balance, 101 ether);

        // Settlment time comes - oracle is called
        vm.expectEmit(true, true, true, true);
        emit InsuranceBroker.PolicySettlementInitiated(
            1,
            holder,
            insurer,
            1 ether,
            100 ether,
            1
        );
        uint64 dataRequestId = broker.settle(policyId);

        // Oracle provider sends data - settlement occurs
        oracle.addProvider(provider);
        vm.prank(provider);
        vm.expectEmit(true, true, true, true);
        emit InsuranceBroker.PolicySettled(
            1,
            holder,
            insurer,
            1 ether,
            100 ether,
            dataRequestId,
            false
        );
        // CBOR:
        // [
        //    1,
        //    true,
        //    [[101]],
        //    "data-hash",
        //    ["did:odf:1", "block-hash"]
        // ]
        oracle.provideResult(
            dataRequestId,
            hex"8501F58181186569646174612D6861736882696469643A6F64663A316A626C6F636B2D68617368"
        );

        assertEq(address(broker).balance, 0 ether);
        assertEq(holder.balance, 0 ether);
        assertEq(insurer.balance, 101 ether);
    }

    function testHappyPathHolderFavor() public {
        address holder = vm.addr(1);
        address insurer = vm.addr(2);
        address provider = vm.addr(3);

        // Holder applies
        deal(holder, 1 ether);
        vm.prank(holder);
        vm.expectEmit(true, true, true, true);
        emit InsuranceBroker.CoverageApplication(1, holder, 1 ether);
        uint64 policyId = broker.applyForCoverage{value: 1 ether}(
            100,
            "did:odf:fed01553538ac45d78e8e7879efb166e592b287f539dd7a0cf5b4d9df8f3fa8a7a899"
        );
        assertEq(holder.balance, 0 ether);

        // Insurer bids
        deal(insurer, 100 ether);
        vm.prank(insurer);
        vm.expectEmit(true, true, true, true);
        emit InsuranceBroker.PolicyCreated(
            1,
            holder,
            insurer,
            1 ether,
            100 ether
        );
        broker.bidForCoverage{value: 100 ether}(policyId);
        assertEq(insurer.balance, 0 ether);

        // Settlment time comes - oracle is called
        vm.expectEmit(true, true, true, true);
        emit InsuranceBroker.PolicySettlementInitiated(
            1,
            holder,
            insurer,
            1 ether,
            100 ether,
            1
        );
        uint64 dataRequestId = broker.settle(policyId);

        // Oracle provider sends data - settlement occurs
        oracle.addProvider(provider);
        vm.prank(provider);
        vm.expectEmit(true, true, true, true);
        emit InsuranceBroker.PolicySettled(
            1,
            holder,
            insurer,
            1 ether,
            100 ether,
            dataRequestId,
            true
        );
        // CBOR:
        // [
        //    1,
        //    true,
        //    [[99]],
        //    "data-hash",
        //    ["did:odf:1", "block-hash"]
        // ]
        oracle.provideResult(
            dataRequestId,
            hex"8501F58181186369646174612D6861736882696469643A6F64663A316A626C6F636B2D68617368"
        );

        assertEq(address(broker).balance, 0 ether);
        //assertEq(holder.balance, 101 ether);
        //assertEq(insurer.balance, 0 ether);
    }

    function testOnResultOnlyOracleRevert() public {
        vm.expectRevert();
        broker.onResult(OdfResponse.empty(1));
    }
}
