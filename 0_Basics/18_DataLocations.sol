// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
storage- переменная - это переменная состояния (хранится в блокчейне)
memory- переменная находится в памяти и существует во время вызова функции
calldata- специальное расположение данных, которое содержит аргументы функции
*/
contract DataLocations {
    uint[] public arr;
    mapping(uint => address) map;
    struct MyStruct {
        uint foo;
    }
    mapping(uint => MyStruct) myStructs;

    function f() public {
        // вызов _f с переменными состояния
        _f(arr, map, myStructs[1]);
        // получить структуру из отображения
        MyStruct storage myStruct = myStructs[1];
        // создаем структуру в памяти
        MyStruct memory myMemStruct = MyStruct(0);
    }

    function _f(
        uint[] storage _arr,
        mapping(uint => address) storage _map,
        MyStruct storage _myStruct
    ) internal {
        // делаем что-то с переменными хранения
    }
    // Вы можете вернуть переменные памяти
    function g(uint[] memory _arr) public returns (uint[] memory) {
        // делаем что-то с массивом памяти
    }

    function h(uint[] calldata _arr) external {
        // делаем что-то с массивом calldata
    }
}
