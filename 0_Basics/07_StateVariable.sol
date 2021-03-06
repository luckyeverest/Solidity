// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Чтобы записать или обновить переменную состояния, вам нужно отправить транзакцию.
С другой стороны, вы можете читать переменные состояния бесплатно, без комиссии за транзакцию.
*/
contract SimpleStorage {
    // Переменная состояния для хранения числа
    uint public num;

    // Вам нужно отправить транзакцию для записи в переменную состояния.
    function set(uint _num) public {
        num = _num;
    }
    // Вы можете читать переменную состояния без отправки транзакции.
    function get() public view returns (uint) {
        return num;
    }
}
