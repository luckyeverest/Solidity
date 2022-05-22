// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Counter {

    uint public count;

    // Функция для получения текущего количества
    function get() public view returns (uint) {
        return count;
    }
    // Функция для увеличения счетчика на 1
    function inc() public {
        count += 1;
    }

    // Функция для уменьшения счетчика на 1
    function dec() public {
        // Эта функция завершится ошибкой, если count = 0
        count -= 1;
    }
}
