// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Модификаторы — это код, который можно запустить до и/или после вызова функции.

Модификаторы можно использовать для:
Ограничить доступ
Проверка входных данных
Защита от взлома с повторным входом
*/
contract FunctionModifier {
    //Мы будем использовать эти переменные, чтобы продемонстрировать, как использовать модификаторы.
    address public owner;
    uint public x = 10;
    bool public locked;

    constructor() {
        // Установите отправителя транзакции в качестве владельца контракта.
        owner = msg.sender;
    }

    // Модификатор для проверки того, что вызывающий объект является владельцем контракта.
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        // Подчеркивание — это специальный символ, используемый только внутри
        // модификатор функции, и он указывает Solidity выполнить остальную часть кода.
        _;
    }

    // Модификаторы могут принимать входные данные. Этот модификатор проверяет, что
    // переданный адрес не является нулевым адресом.
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner validAddress(_newOwner) {
        owner = _newOwner;
    }

    // Модификаторы можно вызывать до и/или после функции.
    // Этот модификатор предотвращает вызов функции во время ее выполнения.
    modifier noReentrancy() {
        require(!locked, "No reentrancy");

        locked = true;
        _;
        locked = false;
    }

    function decrement(uint i) public noReentrancy {
        x -= i;

        if (i > 1) {
            decrement(i - 1);
        }
    }
}
