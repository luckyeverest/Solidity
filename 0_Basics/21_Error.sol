// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Ошибка отменяет все изменения, внесенные в состояние во время транзакции.

Вы можете выдать ошибку, вызвав require, revert или assert.

require используется для проверки входных данных и условий перед выполнением.
revert похож на require.
assert используется для проверки кода, который никогда не должен быть ложным.
Неудачное утверждение, вероятно, означает, что есть ошибка.
Используйте пользовательскую ошибку для экономии газа.
*/
contract Error {
    function testRequire(uint _i) public pure {
        // Require следует использовать для проверки таких условий, как:
         // - входы
         // - условия перед выполнением
         // - возвращаем значения из вызовов других функций
         //Ввод должен быть больше 10
        require(_i > 10, "Input must be greater than 10");
    }

    function testRevert(uint _i) public pure {
        // revert полезен, когда условие для проверки сложное.
        // Этот код делает то же самое, что и в примере выше
        if (_i <= 10) {
            revert("Input must be greater than 10");
        }
    }

    uint public num;

    function testAssert() public view {
        // Assert следует использовать только для проверки внутренних ошибок,
         // и проверить инварианты.

         // Здесь мы утверждаем, что число всегда равно 0
         // так как невозможно обновить значение num
        assert(num == 0);
    }

    // пользовательская ошибка
    error InsufficientBalance(uint balance, uint withdrawAmount);

    function testCustomError(uint _withdrawAmount) public view {
        uint bal = address(this).balance;
        if (bal < _withdrawAmount) {
            revert InsufficientBalance({balance: bal, withdrawAmount: _withdrawAmount});
        }
    }
}
