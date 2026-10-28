// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EscrowRelease {
    enum Status {
        Funded,
        Released,
        Refunded
    }

    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public amount;
    Status public status;

    error NotAuthorized();
    error BadStatus();
    error TransferFailed();

    event Released(address indexed to, uint256 amount);

    constructor(address _buyer, address _seller, address _arbiter) payable {
        buyer = _buyer;
        seller = _seller;
        arbiter = _arbiter;
        amount = msg.value;
        status = Status.Funded;
    }

    function release() external {
        if (msg.sender != buyer && msg.sender != arbiter) revert NotAuthorized();
        if (status != Status.Funded) revert BadStatus();
        uint256 payment = amount;
        status = Status.Released;
        amount = 0;
        (bool success, ) = seller.call{value: payment}("");
        if (!success) rever TransferFailed();
        emit Released(seller, payment);
    }
}