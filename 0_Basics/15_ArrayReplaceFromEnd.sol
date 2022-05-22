// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
//Удалить элемент массива, скопировав последний элемент в место для удаления
contract ArrayReplaceFromEnd {
    uint[] public arr;
    // Удаление элемента создает пробел в массиве.
    // Одна из хитростей, позволяющая сохранить компактность массива, состоит в том, чтобы
    // перемещаем последний элемент на место для удаления.
    function remove(uint index) public {
        // Перемещаем последний элемент на место для удаления
        arr[index] = arr[arr.length - 1];
        // Удалить последний элемент
        arr.pop();
    }

    function test() public {
        arr = [1, 2, 3, 4];

        remove(1);
        // [1, 4, 3]
        assert(arr.length == 3);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
        assert(arr[2] == 3);

        remove(2);
        // [1, 4]
        assert(arr.length == 2);
        assert(arr[0] == 1);
        assert(arr[1] == 4);
    }
}
