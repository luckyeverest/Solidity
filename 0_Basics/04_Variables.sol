// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
В Solidity есть 3 типа переменных

local- объявлен внутри функции не хранится в блокчейне
state- объявлен вне функции хранится в блокчейне
global-(предоставляет информацию о блокчейне)
*/
contract Variables {
    // Переменные состояния хранятся в блокчейне.
    string public text = "Hello";
    uint public num = 123;

    function doSomething() public {
        // Локальные переменные не сохраняются в блокчейне.
        uint i = 456;

        // некоторые глобальные переменные
        uint timestamp = block.timestamp; // Временная метка текущего блока
        address sender = msg.sender; // адрес отправителя
    }
}
