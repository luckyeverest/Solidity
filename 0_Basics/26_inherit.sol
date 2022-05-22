// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Solidity поддерживает множественное наследование. 
Контракты могут наследовать другие контракты с помощью ключевого слова is.

Функция, которая будет переопределена дочерним контрактом,
должна быть объявлена виртуальной.

Функция, которая переопределяет родительскую функцию, 
должна использовать ключевое слово override.

Порядок наследования важен.

Вы должны перечислить родительские контракты в порядке от 
«наиболее похожих на базовые» до «наиболее производных».
*/
/* График наследования
    A
   / \
  B   C
 / \ /
F  D,E
*/

contract A {
    function foo() public pure virtual returns (string memory) {
        return "A";
    }
}
// Контракты наследуют другие контракты, используя ключевое слово 'is'.
contract B is A {
    // Переопределить A.foo()
    function foo() public pure virtual override returns (string memory) {
        return "B";
    }
}

contract C is A {
    // Переопределить A.foo()
    function foo() public pure virtual override returns (string memory) {
        return "C";
    }
}

// Контракты могут наследоваться от нескольких родительских контрактов.
// Когда вызывается функция, которая определена несколько раз в
// разные контракты, поиск родительских контрактов справа налево и в глубину.

contract D is B, C {
    // D.foo() возвращает "C"
    // так как C является самым правым родительским контрактом с функцией foo()
    function foo() public pure override(B, C) returns (string memory) {
        return super.foo();
    }
}

contract E is C, B {
    // E.foo() возвращает "B"
    // так как B является самым правым родительским контрактом с функцией foo()
    function foo() public pure override(C, B) returns (string memory) {
        return super.foo();
    }
}

// Наследование должно быть упорядочено от «наиболее базового» к «наиболее производному».
// Замена порядка A и B вызовет ошибку компиляции.
contract F is A, B {
    function foo() public pure override(A, B) returns (string memory) {
        return super.foo();
    }
}
