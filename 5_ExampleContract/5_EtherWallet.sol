// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//кошелек эфира
contract EtherWallet {
    //адрес владельца
    address payable public owner;

    //владелец = отправитель
    constructor() {
        owner = payable(msg.sender);
    }
    //получить
    receive() external payable {}
    //изьять (колво)
    function withdraw(uint _amount) external {
        //требовать отправитель= владелец
        require(msg.sender == owner, "caller is not owner");
        //отправить колво владельцу
        payable(msg.sender).transfer(_amount);
    }
    //функция получения баланса
    function getBalance() external view returns (uint) {
        //вернуть баланс этого адреса
        return address(this).balance;
    }
}