// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
События позволяют войти в блокчейн Ethereum. Некоторые варианты использования событий:
Прослушивание событий и обновление пользовательского интерфейса
Дешевая форма хранения
*/
contract Event {
    // Объявление события
     // Можно индексировать до 3 параметров.
     // Индексированные параметры помогают фильтровать журналы по индексированному параметру
    event Log(address indexed sender, string message);
    event AnotherLog();

    function test() public {
        emit Log(msg.sender, "Hello World!");
        emit Log(msg.sender, "Hello EVM!");
        emit AnotherLog();
    }
}
