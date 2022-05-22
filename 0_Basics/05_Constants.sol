// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Константы — это переменные, которые нельзя изменить.
Их значение жестко закодировано, и использование констант может сэкономить затраты на газ.
*/
contract Constants {
    // соглашение о кодировании для переменных-констант в верхнем регистре
    address public constant MY_ADDRESS = 0x777788889999AaAAbBbbCcccddDdeeeEfFFfCcCc;
    uint public constant MY_UINT = 123;
}
