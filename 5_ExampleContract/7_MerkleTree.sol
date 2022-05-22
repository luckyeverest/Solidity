// SPDX-License-Identifier: MIT

//Дерево Меркла позволяет криптографически доказать, что элемент содержится в наборе,
// не раскрывая весь набор.
pragma solidity ^0.8.13;

// доказательство меркла
contract MerkleProof {
    //функция проверки (создания корневого хеша)
    function verify(
        bytes32[] memory proof,//доказательство массив хешей для вычисления
        bytes32 root,//корень
        bytes32 leaf,//лист хеш элемнта который требовался для постраения
        uint index//индекс где хранится элемент
    ) public pure returns (bool) {//врозвращает правду или лож 
        //лист это хеш размером 32 байта
        bytes32 hash = leaf;
        //цикл от 0 по длине доказательства с шагом один
        for (uint i = 0; i < proof.length; i++) {
            //элемент доказательства = доказательству под индексом i
            bytes32 proofElement = proof[i];
            //если индекс делится на 2 (четный) хешируем элесент
            if (index % 2 == 0) {
                hash = keccak256(abi.encodePacked(hash, proofElement));
            } else {
                //(не четный) добавляем не достающий хеш и хешируем
                hash = keccak256(abi.encodePacked(proofElement, hash));
            }
            //делим порядковый номер на 2 так как дерево уменьшается с каждым разом на 2 элмента
            index = index / 2;
        }
        //возвращаем корневый хеш
        return hash == root;
    }
}
//тестовый контракт 
contract TestMerkleProof is MerkleProof {
    bytes32[] public hashes;
    //конструктор с 4 элементами
    constructor() {
        string[4] memory transactions = [
            "alice -> bob",
            "bob -> dave",
            "carol -> alice",
            "dave -> bob"
        ];
        //цикл проходящий по массиву transactions и хеширующий данные
        for (uint i = 0; i < transactions.length; i++) {
            hashes.push(keccak256(abi.encodePacked(transactions[i])));
        }
        //длина массива
        uint n = transactions.length;
        uint offset = 0;
        //цикл добавляющий в масив хешей 
        while (n > 0) {
            for (uint i = 0; i < n - 1; i += 2) {
                hashes.push(
                    keccak256(
                        abi.encodePacked(hashes[offset + i], hashes[offset + i + 1])
                    )
                );
            }
            offset += n;
            n = n / 2;
        }
    }
    //функция вохвращающая корень
    function getRoot() public view returns (bytes32) {
        return hashes[hashes.length - 1];
    }

    /* verify
    3rd leaf
    0x1bbd78ae6188015c4a6772eb1526292b5985fc3272ead4c65002240fb9ae5d13

    root
    0x074b43252ffb4a469154df5fb7fe4ecce30953ba8b7095fe1e006185f017ad10

    index
    2

    proof
    0x948f90037b4ea787c14540d9feb1034d4a5bc251b9b5f8e57d81e4b470027af8
    0x63ac1b92046d474f84be3aa0ee04ffe5600862228c81803cce07ac40484aee43
    */
}