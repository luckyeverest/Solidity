// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract EtherUnits {
    uint public oneWei = 1 wei;
    // 1 вэй равно 1
    bool public isOneWei = 1 wei == 1;

    uint public oneEther = 1 ether;
    // 1 эфир равен 10^18 вэй
    bool public isOneEther = 1 ether == 1e18;
}
