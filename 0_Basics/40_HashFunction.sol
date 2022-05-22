/*
keccak256вычисляет хэш ввода Keccak-256.

Некоторые варианты использования:
Создание детерминированного уникального идентификатора из ввода
Схема Commit-Reveal
Компактная криптографическая подпись (подписывая хэш вместо ввода большего размера)
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract HashFunction {
    function hash(
        string memory _text,
        uint _num,
        address _addr
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_text, _num, _addr));
    }

    // Пример коллизии хешей
     // Коллизия хэшей может произойти, если вы передаете более одного динамического типа данных
     // в abi.encodePacked. В таком случае вам следует использовать вместо него abi.encode.
    function collision(string memory _text, string memory _anotherText)
        public
        pure
        returns (bytes32)
    {
        // encodePacked(AAA, BBB) -> AAABBB
        // encodePacked(AA, ABBB) -> AAABBB
        return keccak256(abi.encodePacked(_text, _anotherText));
    }
}

contract GuessTheMagicWord {
    bytes32 public answer =
        0x60298f78cc0b47170ba79c10aa3851d7648bd96f2f8e46a19dbc777c36fb0c00;

    // Волшебное слово "Солидность"
    function guess(string memory _word) public view returns (bool) {
        return keccak256(abi.encodePacked(_word)) == answer;
    }
}
