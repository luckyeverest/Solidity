// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Вы можете определить свой собственный тип, создав файл struct.
Они полезны для группировки связанных данных.
Структуры могут быть объявлены вне контракта и импортированы в другой контракт.
*/
contract Todos {
    struct Todo {
        string text;
        bool completed;
    }
    // Массив структур Todo
    Todo[] public todos;

    function create(string calldata _text) public {
        // 3 способа инициализации структуры
        // - вызываем как функцию
        todos.push(Todo(_text, false));
        // сопоставление значения ключа
        todos.push(Todo({text: _text, completed: false}));
        // инициализируем пустую структуру, а затем обновляем ее
        Todo memory todo;
        todo.text = _text;
        // todo.completed инициализируется значением false
        todos.push(todo);
    }

    // Solidity автоматически создала геттер для todos, поэтому
    // на самом деле вам не нужна эта функция.
    function get(uint _index) public view returns (string memory text, bool completed) {
        Todo storage todo = todos[_index];
        return (todo.text, todo.completed);
    }
    // обновляем текст
    function updateText(uint _index, string calldata _text) public {
        Todo storage todo = todos[_index];
        todo.text = _text;
    }
    // обновление завершено
    function toggleCompleted(uint _index) public {
        Todo storage todo = todos[_index];
        todo.completed = !todo.completed;
    }
}
/*
Объявление и импорт Struct
Файл, в котором объявлена ​​структура
pragma solidity ^0.8.13;
// This is saved 'StructDeclaration.sol'

struct Todo {
    string text;
    bool completed;
}

Файл, который импортирует структуру выше

pragma solidity ^0.8.13;

import "./StructDeclaration.sol";

contract Todos {
    // An array of 'Todo' structs
    Todo[] public todos;
}
*/