// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
Конструктор — это необязательная функция, которая выполняется при создании контракта.

Вот примеры того, как передавать аргументы конструкторам.
*/
// Базовый контракт X
contract X {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

// Базовый контракт Y
contract Y {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}

// Есть 2 способа инициализировать родительский контракт с параметрами.

// Передаем параметры здесь, в списке наследования.
contract B is X("Input to X"), Y("Input to Y") {

}

contract C is X, Y {
    // Передаем параметры здесь в конструкторе, аналогично модификаторам функций.
    constructor(string memory _name, string memory _text) X(_name) Y(_text) {}
}

// Родительские конструкторы всегда вызываются в порядке наследования
// независимо от порядка расположения родительских контрактов в списке
// конструктор дочернего контракта.

// Порядок вызова конструкторов:
// 1. X
// 2. Y
// 3. D
contract D is X, Y {
    constructor() X("X was called") Y("Y was called") {}
}

// Заказ конструкторов называется:
// 1. X
// 2. Y
// 3. E
contract E is X, Y {
    constructor() Y("Y was called") X("X was called") {}
}
