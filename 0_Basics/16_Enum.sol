// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
//Solidity поддерживает перечисления, и они полезны 
//для моделирования выбора и отслеживания состояния.
//Перечисления могут быть объявлены вне контракта.
contract Enum {
    // Перечисление, представляющее статус доставки
    enum Status {
        Pending,
        Shipped,
        Accepted,
        Rejected,
        Canceled
    }

    // Значением по умолчанию является первый элемент, указанный в
    // определение типа, в данном случае "Ожидание"
    Status public status;

// Возвращает значение
     // В ожидании - 0
     // Отправлено - 1
     // Принято - 2
     // Отклонено - 3
     // Отменено - 4
    function get() public view returns (Status) {
        return status;
    }
    // Обновляем статус, передавая uint на вход
    function set(Status _status) public {
        status = _status;
    }
    // Вы можете обновить до определенного перечисления, как это
    function cancel() public {
        status = Status.Canceled;
    }
    // delete сбрасывает перечисление до его первого значения, 0
    function reset() public {
        delete status;
    }
}

/*
Файл, в котором объявлено перечисление
pragma solidity ^0.8.13;
// This is saved 'EnumDeclaration.sol'

enum Status {
    Pending,
    Shipped,
    Accepted,
    Rejected,
    Canceled
}

Файл, который импортирует указанное выше перечисление
pragma solidity ^0.8.13;

import "./EnumDeclaration.sol";

contract Enum {
    Status public status;
}
*/