// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
В отличие от функций, переменные состояния нельзя переопределить, 
повторно объявив их в дочернем контракте.
*/
contract A {
    string public name = "Contract A";

    function getName() public view returns (string memory) {
        return name;
    }
}

// Затенение запрещено в Solidity 0.6
// Это не скомпилируется
// контракт B — это A {
// string public name = "Contract B";
// }

contract C is A {
    // Это правильный способ переопределить унаследованные переменные состояния.
    constructor() {
        name = "Contract C";
    }

    // C.getName возвращает "Контракт C"
}
