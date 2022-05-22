// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Primitives {
    bool public boo = true;

    /*
    uint означает целое число без знака, то есть неотрицательные целые числа
     доступны разные размеры
         uint8 находится в диапазоне от 0 до 2 ** 8 - 1
         uint16 находится в диапазоне от 0 до 2 ** 16 - 1
         ...
         uint256 находится в диапазоне от 0 до 2 ** 256 - 1
    */
    uint8 public u8 = 1;
    uint public u256 = 456;
    uint public u = 123; // uint — это псевдоним для uint256.

    /*
    Отрицательные числа разрешены для типов int.
     Как и uint, доступны различные диапазоны от int8 до int256.
    
     int256 находится в диапазоне от -2 ** 255 до 2 ** 255 - 1
     int128 находится в диапазоне от -2 ** 127 до 2 ** 127 - 1
    */
    int8 public i8 = -1;
    int public i256 = 456;
    int public i = -123; // int такой же, как int256

    // минимум и максимум int
    int public minInt = type(int).min;
    int public maxInt = type(int).max;

    address public addr = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;

    /*
    В Solidity тип данных byte представляет собой последовательность байтов.
     Solidity представляет два типа типов байтов:

      - байтовые массивы фиксированного размера
      - байтовые массивы с динамическим размером.
     
      Термин байты в Solidity представляет собой динамический массив байтов.
      Это сокращение от byte[] .
    */
    bytes1 a = 0xb5; //  [10110101]
    bytes1 b = 0x56; //  [01010110]

    // Значения по умолчанию
    // Неназначенные переменные имеют значение по умолчанию
    bool public defaultBoo; // false
    uint public defaultUint; // 0
    int public defaultInt; // 0
    address public defaultAddr; // 0x0000000000000000000000000000000000000000
}
