// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
//Сообщения могут быть подписаны вне цепочки, 
//а затем проверены в цепочке с использованием смарт-контракта.
/* Проверка подписи

Как подписать и подтвердить
# Подписание
1. Создайте сообщение для подписи
2. Хэшируйте сообщение
3. Подпишите хэш (вне сети, держите секретный ключ в секрете)

# Проверять
1. Воссоздайте хэш из исходного сообщения
2. Восстановить подписавшего из подписи и хеша
3. Сравните восстановленную подписывающую сторону с заявленной подписывающей стороной
*/

contract VerifySignature {
    /* 1.Разблокировать учетную запись MetaMask
    ethereum.enable()
    */

    /* 2.Получить хэш сообщения для подписи
    getMessageHash(
        0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C,
        123,
        "coffee and donuts",
        1
    )

    hash = "0xcf36ac4f97dc10d91fc2cbb20d718e94a8cbfe0f82eaedc6a4aa38946fb797cd"
    */
    function getMessageHash(
        address _to,
        uint _amount,
        string memory _message,
        uint _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    /* 3. Подписать хэш сообщения
     # с помощью браузера
    account = "copy paste account of signer here"
    ethereum.request({ method: "personal_sign", params: [account, hash]}).then(console.log)

    # использование web3
    web3.personal.sign(hash, web3.eth.defaultAccount, console.log)

    Подпись будет разной для разных аккаунтов
    0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */
    function getEthSignedMessageHash(bytes32 _messageHash)
        public
        pure
        returns (bytes32)
    {
        /*
        Подпись создается путем подписания хэша keccak256 в следующем формате:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }

    /* 4. Подтвердить подпись
    signer = 0xB273216C05A8c0D4F0a4Dd0d7Bae1D2EfFE636dd
    to = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
    amount = 123
    message = "coffee and donuts"
    nonce = 1
    signature =
        0x993dab3dd91f5c6dc28e17439be475478f5635c92a56e17e82349d3fb2f166196f466c0b4e0c146f285204f0dcb13e5ae67bc33f4b888ec32dfe0a063e8f3f781b
    */
    function verify(
        address _signer,
        address _to,
        uint _amount,
        string memory _message,
        uint _nonce,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        public
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            Первые 32 байта хранят длину подписи.

            add(sig, 32) = pointer of sig + 32
            эффективно пропускает первые 32 байта подписи

            mload(p) загружает следующие 32 байта, начиная с адреса памяти p, в память
            */

            // первые 32 байта после префикса длины
            r := mload(add(sig, 32))
            // второй 32 байта
            s := mload(add(sig, 64))
            // последний байт (первый байт из следующих 32 байтов)
            v := byte(0, mload(add(sig, 96)))
        }

        // неявно вернуть (r, s, v)
    }
}
