// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/* Дерево наследования
   A
 /  \
B   C
 \ /
  D
*/

contract A {
    // Это называется событием. Вы можете испускать события из своей функции
     // и они регистрируются в журнале транзакций.
     // В нашем случае это будет полезно для отслеживания вызовов функций.
    event Log(string message);

    function foo() public virtual {
        emit Log("A.foo called");
    }

    function bar() public virtual {
        emit Log("A.bar called");
    }
}

contract B is A {
    function foo() public virtual override {
        emit Log("B.foo called");
        A.foo();
    }

    function bar() public virtual override {
        emit Log("B.bar called");
        super.bar();
    }
}

contract C is A {
    function foo() public virtual override {
        emit Log("C.foo called");
        A.foo();
    }

    function bar() public virtual override {
        emit Log("C.bar called");
        super.bar();
    }
}

contract D is B, C {
    // Пытаться:
     // - Вызовите D.foo и проверьте журналы транзакций.
     // Хотя D наследует A, B и C, он вызывает только C, а затем A.
     // - Вызываем D.bar и проверяем логи транзакций
     // D вызывает C, затем B и, наконец, A.
     // Хотя super был вызван дважды (B и C), он вызвал A только один раз.

    function foo() public override(B, C) {
        super.foo();
    }

    function bar() public override(B, C) {
        super.bar();
    }
}
