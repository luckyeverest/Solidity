// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Base {
    // Приватная функция может быть вызвана только
    // - внутри этого контракта
    // Контракты, которые наследуют этот контракт, не могут вызывать эту функцию.
    function privateFunc() private pure returns (string memory) {
        return "private function called";
    }

    function testPrivateFunc() public pure returns (string memory) {
        return privateFunc();
    }

    // Внутренняя функция может быть вызвана
     // - внутри этого контракта
     // - внутри контрактов, которые наследуют этот контракт
    function internalFunc() internal pure returns (string memory) {
        return "internal function called";
    }

    function testInternalFunc() public pure virtual returns (string memory) {
        return internalFunc();
    }

    // Публичные функции могут быть вызваны
     // - внутри этого контракта
     // - внутри контрактов, которые наследуют этот контракт
     // - по другим контрактам и счетам
    function publicFunc() public pure returns (string memory) {
        return "public function called";
    }

    // Внешние функции можно вызывать только
     // - по другим контрактам и счетам
    function externalFunc() external pure returns (string memory) {
        return "external function called";
    }
    // Эта функция не скомпилируется, так как мы пытаемся вызвать здесь внешняя функция.
     // функция testExternalFunc() public pure возвращает (строковая память) { вернуть externalFunc();
     // }

     // Переменные состояния
    string private privateVar = "my private variable";
    string internal internalVar = "my internal variable";
    string public publicVar = "my public variable";
    // Переменные состояния не могут быть внешними, поэтому этот код не будет компилироваться.
     // string external externalVar = "моя внешняя переменная";
}

contract Child is Base {
    // Унаследованные контракты не имеют доступа к закрытым функциям
     // и переменные состояния.
     // функция testPrivateFunc() public pure возвращает (строковая память) {
     // вернуть privateFunc();
     // }

     // Внутренний вызов функции внутри дочерних контрактов.
    function testInternalFunc() public pure override returns (string memory) {
        return internalFunc();
    }
}
