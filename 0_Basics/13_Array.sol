// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Array {
    // Несколько способов инициализации массива
    uint[] public arr;
    uint[] public arr2 = [1, 2, 3];
    // Массив фиксированного размера, все элементы инициализируются 0
    uint[10] public myFixedSizeArr;

    //получение
    function get(uint i) public view returns (uint) {
        return arr[i];
    }

    // Solidity может вернуть весь массив.
     // Но эту функцию следует избегать для
     // массивы, длина которых может увеличиваться до бесконечности.
    function getArr() public view returns (uint[] memory) {
        return arr;
    }

    function push(uint i) public {
        // Добавляем в массив
         // Это увеличит длину массива на 1.
        arr.push(i);
    }

    function pop() public {
        // Удалить последний элемент из массива
         // Это уменьшит длину массива на 1
        arr.pop();
    }
    //длинна массива
    function getLength() public view returns (uint) {
        return arr.length;
    }

    function remove(uint index) public {
        // Удаление не меняет длину массива.
         // Он сбрасывает значение по индексу до значения по умолчанию,
         // в данном случае 0
        delete arr[index];
    }

    function examples() external{
        // создать массив в памяти, можно создать только фиксированный размер
        uint[] memory a = new uint[](5);
    }
}
