// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//Если у вас есть контракт, который будет развернут несколько раз,
// используйте минимальный прокси-контракт, чтобы развертывать их дешевле.


contract MinimalProxy {
    function clone(address target) external returns (address result) {
        // преобразовать адрес в 20 байт
        bytes20 targetBytes = bytes20(target);
        // фактический код //
        // 3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
        // код создания //
        // копируем исполняемый код в память и возвращаем его
        // 3d602d80600a3d3981f3

        // код времени выполнения //
        // код для делегирования вызова по адресу
        // 363d3d373d3d3d363d73 address 5af43d82803e903d91602b57fd5bf3

        assembly {
            /*
           читает 32 байта памяти, начиная с указателя, хранящегося в 0x40

             В солидности слот 0x40 в памяти особенный: он содержит «указатель свободной памяти»
             который указывает на конец выделенной в данный момент памяти.
            */
            let clone := mload(0x40)
            // сохраняем в памяти 32 байта, начиная с "clone"
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )

            /*
              |              20 bytes                |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
                                                      ^
                                                      указатель
            */
            // сохраняем в памяти 32 байта, начиная с "clone" + 20 байт
            // 0x14 = 20
            mstore(add(clone, 0x14), targetBytes)

            /*
              |               20 bytes               |                 20 bytes              |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe
                                                                                              ^
                                                                                              указатель
            */
            // сохранить 32 байта в памяти, начиная с «клона» + 40 байтов
            // 0x28 = 40
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )

            /*
              |               20 bytes               |                 20 bytes              |           15 bytes          |
            0x3d602d80600a3d3981f3363d3d373d3d3d363d73bebebebebebebebebebebebebebebebebebebebe5af43d82803e903d91602b57fd5bf3
            */
            // создаем новый контракт
             // отправить 0 Эфир
             // код начинается с указателя, хранящегося в "clone"
             // размер кода 0x37 (55 байт)
            result := create(0, clone, 0x37)
        }
    }
}
