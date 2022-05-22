// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
/*
Не создавайте неограниченные циклы, так как это может привести 
к превышению лимита газа, что приведет к сбою транзакции.
По вышеуказанной причине whileи do while петли используются редко.
*/
contract Loop {
    function loop() public pure{
        // for
        for (uint i = 0; i < 10; i++) {
            if (i == 3) {
                // Перейти к следующей итерации с помощью продолжить
                continue;
            }
            if (i == 5) {
                // Выход из цикла с перерывом
                break;
            }
        }

        // while 
        uint j;
        while (j < 10) {
            j++;
        }
    }
}
