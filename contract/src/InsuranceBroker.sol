// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {OdfRequest, OdfResponse, IOdfClient, CborReader} from "@opendatafabric/contracts/src/Odf.sol";
// import { console2 } from "forge-std/src/console2.sol";

// Example weather insurance broker contract
contract InsuranceBroker {
    event CoverageApplication(
        uint64 indexed policyId,
        address indexed holder,
        uint holderDeposit
    );

    event PolicyCreated(
        uint64 indexed policyId,
        address indexed holder,
        address indexed insurer,
        uint holderDeposit,
        uint insurerDeposit
    );

    event PolicySettlementInitiated(
        uint64 indexed policyId,
        address indexed holder,
        address indexed insurer,
        uint holderDeposit,
        uint insurerDeposit,
        uint64 dataRequestId
    );

    event PolicySettled(
        uint64 indexed policyId,
        address indexed holder,
        address indexed insurer,
        uint holderDeposit,
        uint insurerDeposit,
        uint64 dataRequestId,
        bool holderClaims
    );

    struct Policy {
        // Identifies the insurance policy
        uint64 policyId;
        // Applicant / beneficiary of the insurance payment and their deposit / premium / cost of the insurance
        address payable holder;
        uint holderDeposit;
        // Underwriter of the insurance and their deposit / settlement amount
        address payable insurer;
        uint insurerDeposit;
        // Whether this policy already settled one way or another
        bool settled;
        // Minimal amount of rainfall that has to be observed for policy to settle in insurer's favor
        uint64 precipitationThreshold;
        // ID of the dataset to use for querying
        string datasetId;
    }

    address private _owner;
    IOdfClient private _oracle;

    uint64 private _lastPolicyId = 0;
    mapping(uint64 policyId => Policy policy) private _policies;
    mapping(uint64 requestId => uint64 policyId) private _dataRequests;

    // Initialize contract with the oracle address
    constructor(address oracleAddr) {
        _owner = msg.sender;
        _oracle = IOdfClient(oracleAddr);
    }

    function applyForCoverage(
        uint64 precipitationThreshold,
        string memory datasetId
    ) external payable returns (uint64) {
        require(msg.value != 0, "need to provide a deposit");

        _lastPolicyId += 1;
        Policy memory policy;
        policy.policyId = _lastPolicyId;
        policy.holder = payable(msg.sender);
        policy.holderDeposit = msg.value;
        policy.precipitationThreshold = precipitationThreshold;
        policy.datasetId = datasetId;

        _policies[policy.policyId] = policy;

        emit CoverageApplication(
            policy.policyId,
            policy.holder,
            policy.holderDeposit
        );

        return policy.policyId;
    }

    function bidForCoverage(uint64 policyId) external payable {
        Policy memory policy = _policies[policyId];

        require(policy.holder != address(0), "policy does not exist");
        require(policy.insurer == address(0), "policy was already accepted");
        require(!policy.settled, "policy was already settled");
        require(
            msg.value > policy.holderDeposit,
            "need to provide sufficient deposit"
        );

        policy.insurer = payable(msg.sender);
        policy.insurerDeposit = msg.value;
        _policies[policyId] = policy;

        emit PolicyCreated(
            policyId,
            policy.holder,
            policy.insurer,
            policy.holderDeposit,
            policy.insurerDeposit
        );
    }

    function settle(uint64 policyId) external returns (uint64) {
        Policy memory policy = _policies[policyId];

        require(policy.holder != address(0), "policy does not exist");

        require(!policy.settled, "policy was already settled");

        // policy was not accepted by an insusrer?
        if (policy.insurer == address(0)) {
            // Return the deposit to the applicant
            policy.settled = true;
            _policies[policyId] = policy;
            policy.holder.transfer(policy.holderDeposit);
            return 0;
        }

        // Request data from the oracle
        OdfRequest.Req memory req = OdfRequest.init();

        // Specify ID of the dataset(s) we will be querying.
        // Repeat this call for multiple inputs.
        req.dataset("weather_stations", policy.datasetId);

        // Specify an arbitrary complex SQL query.
        // Queries can include even JOINs
        req.sql(
            "select "
            "cast(floor(avg(precipitation_accumulated)) as bigint) "
            "from ( "
            "select "
            "device_id, max(precipitation_accumulated) as precipitation_accumulated "
            "from weather_stations "
            "group by device_id "
            ") "
        );

        // Send request to the oracle and specify a callback
        uint64 dataRequestId = _oracle.sendRequest(req, this.onResult);
        _dataRequests[dataRequestId] = policyId;

        emit PolicySettlementInitiated(
            policy.policyId,
            policy.holder,
            policy.insurer,
            policy.holderDeposit,
            policy.insurerDeposit,
            dataRequestId
        );

        return dataRequestId;
    }

    // This function will be called by the oracle when request is fulfilled
    function onResult(OdfResponse.Res memory result) external {
        require(msg.sender == address(_oracle), "Can only be called by oracle");

        uint64 policyId = _dataRequests[result.requestId()];
        require(policyId != 0, "corresponding policy not found");

        Policy memory policy = _policies[policyId];
        require(
            policy.holder != address(0) && policy.insurer != address(0),
            "policy is in invalid state"
        );
        require(!policy.settled, "policy already settled");

        require(result.numRecords() == 1, "Expected one record");

        CborReader.CBOR[] memory record = result.record(0);
        uint64 precipitationActual = uint64(int64(record[0].readInt()));

        bool holderClaims = precipitationActual < policy.precipitationThreshold;

        policy.settled = true;
        _policies[policyId] = policy;

        emit PolicySettled(
            policy.policyId,
            policy.holder,
            policy.insurer,
            policy.holderDeposit,
            policy.insurerDeposit,
            result.requestId(),
            holderClaims
        );

        if (holderClaims) {
            policy.holder.transfer(
                policy.holderDeposit + policy.insurerDeposit
            );
        } else {
            policy.insurer.transfer(
                policy.holderDeposit + policy.insurerDeposit
            );
        }
    }

    function withdraw() external {
        require(msg.sender == _owner, "Only owner can withdraw");
        payable(_owner).transfer(address(this).balance);
    }

    using OdfRequest for OdfRequest.Req;
    using OdfResponse for OdfResponse.Res;
    using CborReader for CborReader.CBOR;
}
