/*
При вызове функции первые 4 байта calldata указывают, какую функцию вызывать.

Эти 4 байта называются селектором функций.

Возьмем, к примеру, этот код ниже.
Он использует вызов для выполнения перевода по контракту на адрес addr.

addr.call(abi.encodeWithSignature("transfer(address,uint256)", 0xSomeAddress, 123))

Первые 4 байта, возвращаемые abi.encodeWithSignature(....), являются селектором функции.

Возможно, вы сможете сэкономить небольшое количество газа, 
если предварительно вычислите и встроите селектор функций в свой код?
*/

//Вот как вычисляется селектор функций.
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract FunctionSelector {
    /*
    "transfer(address,uint256)"
    0xa9059cbb
    "transferFrom(address,address,uint256)"
    0x23b872dd
    */
    function getSelector(string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }
}
