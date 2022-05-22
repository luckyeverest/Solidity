// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
fallback — это функция, которая не принимает никаких аргументов и ничего не возвращает.

Он выполняется либо при
1 функция, которая не существует, вызывается или
2 Эфир отправляется напрямую в контракт, но функция receive() не существует или msg.data не пуст.
резервный вариант имеет лимит газа 2300 при вызове путем передачи или отправки.
*/
contract Fallback {
    event Log(uint gas);

    // Резервная функция должна быть объявлена как внешняя.
    fallback() external payable {
        // send / transfer (перенаправляет 2300 газа на эту резервную функцию)
        // call (направляет весь газ)
        emit Log(gasleft());
    }

    // Вспомогательная функция для проверки баланса этого контракта
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SendToFallback {
    function transferToFallback(address payable _to) public payable {
        _to.transfer(msg.value);
    }

    function callFallback(address payable _to) public payable {
        (bool sent, ) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}
