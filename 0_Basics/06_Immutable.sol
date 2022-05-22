// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Неизменяемые переменные похожи на константы. 
Значения неизменяемых переменных могут быть установлены внутри конструктора, 
но не могут быть изменены впоследствии.
*/
contract Immutable {
    // соглашение о кодировании для переменных-констант в верхнем регистре
    address public immutable MY_ADDRESS;
    uint public immutable MY_UINT;

    constructor(uint _myUint) {
        MY_ADDRESS = msg.sender;
        MY_UINT = _myUint;
    }
}
