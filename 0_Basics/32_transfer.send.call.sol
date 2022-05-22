// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Как отправить эфир?
Вы можете отправить Эфир на другие контракты с помощью

transfer  (2300 газ, выкидывает ошибку)
send  (2300 газа, возвращает bool)
call (переадресовать весь газ или установить газ, возвращает bool)
Как получить эфир?
Контракт, получающий эфир, должен иметь хотя бы одну из перечисленных ниже функций.

receive () внешний платеж
fallback() внешний платеж
Receive() вызывается, если msg.data пуст, в противном случае вызывается fallback().

Какой метод следует использовать?
call в сочетании с защитой от повторного входа является 
рекомендуемым методом для использования после декабря 2019 года.

Защита от повторного входа
выполнение всех изменений состояния перед вызовом других контрактов
использование модификатора защиты от повторного входа
*/
contract ReceiveEther {
    /*
    Какая функция вызывается, fallback() или receive()?
           send Ether
               |
         msg.data is empty?
              / \
            yes  no
            /     \
receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback()
    */

    // Функция получения эфира. msg.data должен быть пустым
    receive() external payable {}

    // Резервная функция вызывается, когда msg.data не пуст.
    fallback() external payable {}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract SendEther {
    function sendViaTransfer(address payable _to) public payable {
        // Эта функция больше не рекомендуется для отправки эфира.
        _to.transfer(msg.value);
    }

    function sendViaSend(address payable _to) public payable {
        // Send возвращает логическое значение, указывающее на успех или неудачу.
         // Эта функция не рекомендуется для отправки эфира.
        bool sent = _to.send(msg.value);
        require(sent, "Failed to send Ether");
    }

    function sendViaCall(address payable _to) public payable {
        // Вызов возвращает логическое значение, указывающее на успех или неудачу.
         // Это текущий рекомендуемый метод для использования.
        (bool sent, bytes memory data) = _to.call{value: msg.value}("");
        require(sent, "Failed to send Ether");
    }
}
