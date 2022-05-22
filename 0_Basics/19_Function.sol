// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Function {
    // Функции могут возвращать несколько значений.
    function returnMany()
        public
        pure
        returns (
            uint,
            bool,
            uint
        )
    {
        return (1, true, 2);
    }
    // Возвращаемые значения могут быть названы.
    function named()
        public
        pure
        returns (
            uint x,
            bool b,
            uint y
        )
    {
        return (1, true, 2);
    }
    // Возвращаемые значения могут быть присвоены их имени.
    // В этом случае оператор return может быть опущен.
    function assigned()
        public
        pure
        returns (
            uint x,
            bool b,
            uint y
        )
    {
        x = 1;
        b = true;
        y = 2;
    }

    // Использовать присваивание деструктурирования при вызове другого
     // функция, которая возвращает несколько значений.
    function destructuringAssignments()
        public
        pure
        returns (
            uint,
            bool,
            uint,
            uint,
            uint
        )
    {
        (uint i, bool b, uint j) = returnMany();

        // Значения можно опустить.
        (uint x, , uint y) = (4, 5, 6);

        return (i, b, j, x, y);
    }

    // Невозможно использовать карту ни для ввода, ни для вывода

    // Может использовать массив для ввода
    function arrayInput(uint[] memory _arr) public {}

    // Можно использовать массив для вывода
    uint[] public arr;

    function arrayOutput() public view returns (uint[] memory) {
        return arr;
    }
}
