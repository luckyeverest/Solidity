// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Функции-получатели могут быть объявлены как view или pure.

view-Функция просмотра объявляет, что никакое состояние не будет изменено.

pure-Чистая функция объявляет, что никакая переменная состояния не будет изменена или прочитана.
*/
contract ViewAndPure {
    uint public x = 1;

    // Обещание не изменять состояние.
    function addToX(uint y) public view returns (uint) {
        return x + y;
    }

    // Обещание не изменять и не читать из состояния.
    function add(uint i, uint j) public pure returns (uint) {
        return i + j;
    }
}
