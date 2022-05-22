// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
delegatecall — это низкоуровневая функция, похожая на call.

Когда контракт A выполняет вызов делегата для контракта B, код B выполняется
с хранилищем контракта А, msg.sender и msg.value.
*/
// ПРИМЕЧАНИЕ. Сначала разверните этот контракт.
contract B {
    // ПРИМЕЧАНИЕ: схема хранения должна быть такой же, как в контракте А.
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
}

contract A {
    uint public num;
    address public sender;
    uint public value;

    function setVars(address _contract, uint _num) public payable {
        //Хранилище A установлено, B не изменено.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
}
