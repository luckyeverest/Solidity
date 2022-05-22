// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
//Функции и адреса, объявленные платными, могут получать эфир в контракт.
contract Payable {
    // Оплачиваемый адрес может получать эфир
    address payable public owner;

    // Платный конструктор может получить эфир
    constructor() payable {
        owner = payable(msg.sender);
    }

    // Функция для внесения эфира в этот контракт.
     // Вызываем эту функцию вместе с эфиром.
     // Баланс этого контракта будет автоматически обновлен.
    function deposit() public payable {}

    // Вызываем эту функцию вместе с эфиром.
     // Функция выдаст ошибку, так как эта функция не подлежит оплате.
    function notPayable() public {}

    // Функция для вывода всего эфира из этого контракта.
    function withdraw() public {
        // получаем количество эфира, хранящегося в этом контракте
        uint amount = address(this).balance;

        // отправляем весь эфир владельцу
         // Владелец может получить эфир, так как адрес владельца подлежит оплате
        (bool success, ) = owner.call{value: amount}("");
        require(success, "Failed to send Ether");
    }

    // Функция для перевода эфира с этого контракта на адрес со входа
    function transfer(address payable _to, uint _amount) public {
        // Обратите внимание, что "to" объявлено как подлежащее оплате
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }
}
