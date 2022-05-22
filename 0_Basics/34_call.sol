// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
call — низкоуровневая функция для взаимодействия с другими контрактами.

Это рекомендуемый метод, когда вы просто отправляете эфир через вызов резервной функции.
Однако это не рекомендуемый способ вызова существующих функций.
*/
contract Receiver {
    event Received(address caller, uint amount, string message);

    fallback() external payable {
        emit Received(msg.sender, msg.value, "Fallback was called");
    }

    function foo(string memory _message, uint _x) public payable returns (uint) {
        emit Received(msg.sender, msg.value, _message);

        return _x + 1;
    }
}

contract Caller {
    event Response(bool success, bytes data);

    // Представим, что у контракта B нет исходного кода для
     // контракт А, но мы знаем адрес А и вызываемую функцию.
    function testCallFoo(address payable _addr) public payable {
        // Вы можете отправить эфир и указать индивидуальное количество газа
        (bool success, bytes memory data) = _addr.call{value: msg.value, gas: 5000}(
            abi.encodeWithSignature("foo(string,uint256)", "call foo", 123)
        );

        emit Response(success, data);
    }

    // Вызов несуществующей функции запускает резервную функцию.
    function testCallDoesNotExist(address _addr) public {
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("doesNotExist()")
        );

        emit Response(success, data);
    }
}
