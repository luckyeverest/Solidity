// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
//Удалить элемент массива, сдвигая элементы справа налево

contract ArrayRemoveByShifting {
    // [1, 2, 3] -- удалить(1) --> [1, 3, 3] --> [1, 3]
    // [1, 2, 3, 4, 5, 6] -- удалить(2) --> [1, 2, 4, 5, 6, 6] --> [1, 2, 4, 5, 6 ]
    // [1, 2, 3, 4, 5, 6] -- удалить(0) --> [2, 3, 4, 5, 6, 6] --> [2, 3, 4, 5, 6 ]
    // [1] -- удалить(0) --> [1] --> []

    uint[] public arr;
    //удаление
    function remove(uint _index) public {
        //требовать индекс меньше длины  иначе индекс за пределами границ
        require(_index < arr.length, "index out of bound");
        //
        for (uint i = _index; i < arr.length - 1; i++) {
            arr[i] = arr[i + 1];
        }
        arr.pop();
    }

    function test() external {
        arr = [1, 2, 3, 4, 5];
        remove(2);
        // [1, 2, 4, 5]
        assert(arr[0] == 1);
        assert(arr[1] == 2);
        assert(arr[2] == 4);
        assert(arr[3] == 5);
        assert(arr.length == 4);

        arr = [1];
        remove(0);
        // []
        assert(arr.length == 0);
    }
}
