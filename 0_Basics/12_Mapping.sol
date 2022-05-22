// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Карты создаются с синтаксисом mapping(keyType => valueType).
Это keyType может быть любой встроенный тип значения, байты, строка или любой контракт.
valueType может быть любого типа, включая другое отображение или массив.
Сопоставления не повторяются.
*/
contract Mapping {
    // Сопоставление адреса с uint
    mapping(address => uint) public myMap;

    function get(address _addr) public view returns (uint) {
        // Отображение всегда возвращает значение.
         // Если значение никогда не устанавливалось, будет возвращено значение по умолчанию.
        return myMap[_addr];
    }

    function set(address _addr, uint _i) public {
        // Обновите значение по этому адресу
        myMap[_addr] = _i;
    }

    function remove(address _addr) public {
        // Сбросьте значение до значения по умолчанию.
        delete myMap[_addr];
    }
}
//вложенный mapping
contract NestedMapping {
    // Вложенное сопоставление (сопоставление адреса с другим сопоставлением)
    mapping(address => mapping(uint => bool)) public nested;

    function get(address _addr1, uint _i) public view returns (bool) {
        // Вы можете получить значения из вложенного сопоставления
        // даже если он не инициализирован
        return nested[_addr1][_i];
    }
    //добавление
    function set(
        address _addr1,
        uint _i,
        bool _boo
    ) public {
        nested[_addr1][_i] = _boo;
    }
    //удалить
    function remove(address _addr1, uint _i) public {
        delete nested[_addr1][_i];
    }
}
