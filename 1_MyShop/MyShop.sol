// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MyShop {

    // создание владельца (адрес)
    address public owner;
    //сохнание информаци кто прислад средства
    //mapping храние информации ключ-значение 
    //ключ адрес, значение колво 
    //payments название переменой
    mapping (address => uint) public payments;
    // коструктор вызывается в момент развертывания контракта
    constructor() {
        //msg.sender возвращает адрес отправителя
        //операцией присваивания кто развернул тот и владелец
        //сохраняется в блокчейн
        owner = msg.sender;
    }
        //payable помечается функции которые могут принять деньги
        //если в функцию передать средства(без тела функции),то она зачислить их на контракт
        //зачисление происходит автоматически
    function payForItem() public payable {
        //обращение к mapping [] - ключ (т.е. адрес отправителя)
        payments[msg.sender] = msg.value;
    }

    function withdrawAll() public {
        address payable _to = payable(owner);
        address _thisContract = address(this);
        _to.transfer(_thisContract.balance);
    }
}