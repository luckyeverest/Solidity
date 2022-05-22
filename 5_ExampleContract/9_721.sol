// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

//ERC-721 — это стандарт токенов для невзаимозаменяемых токенов на Ethereum
//интерфес контракта IERC165 
interface IERC165 {
    //функция поддерживания интерфейса возвращает логическое значение
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
//интерфейс IERC721 наследуемый от IERC165
interface IERC721 is IERC165 {
    //функция баланса владельца  принимающая адрес возвращающая баланс
    function balanceOf(address owner) external view returns (uint balance);
    //функция владельца принимающая индификатор токена возвращающая адрес владельца
    function ownerOf(uint tokenId) external view returns (address owner);

    //функция безопасного транзакции из(принимающая адрес откуда,адрес куда, индификатор токена)
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external;
        //функция безопасного транзакции из(принимающая адрес откуда,адрес куда, индификатор токена)
        //calldata с вызовом информации
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes calldata data
    ) external;
    //перевод из (принимающая адрес откуда,адрес куда, индификатор токена)
    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external;
    //функция одобрения(адрес откуда,индификатор токена)
    function approve(address to, uint tokenId) external;
    //функция получения одобрения(индификатор токена)
    function getApproved(uint tokenId) external view returns (address operator);
    //функция установления одобрения для всех (адрес оператора,одобрение)
    function setApprovalForAll(address operator, bool _approved) external;
    //функция есть установленное одобрения для всех (владелец,оператор )
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}
//интерфейс принимающий IERC721
interface IERC721Receiver {
    //функция принимающая (оператора,откуда,индификатор токена,вызов инф)возвращающая значениев 4 байта
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
//контракт наследуемый от интерфеса
contract ERC721 is IERC721 {
    //использующий адрес
    using Address for address;
    //событие перевода(адерс откуда,куда,индификатор токена)
    event Transfer(address indexed from, address indexed to, uint indexed tokenId);
    //событие одобрения (владелец,ободпренно,индификатор токена)
    event Approval(
        address indexed owner,
        address indexed approved,
        uint indexed tokenId
    );
    //событие одобрение всего(владелец,оператор,одобренно)
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Mapping от идентификатора токена до адреса владельца
    mapping(uint => address) private _owners;

    // Mapping адрес владельца для количества токенов
    mapping(address => uint) private _balances;

    // Mapping от идентификатора токена до утвержденного адреса
    mapping(uint => address) private _tokenApprovals;

    // Mapping от владельца до согласования с оператором
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    //функция поддерживает интерфейс(принимающая индификатор интерфейса) озвращающая bool
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        //возвращающая индификатор интервейса IERC721 или IERC165
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }
    //функция баланса (принимаетя адрес владельца)
    function balanceOf(address owner) external view override returns (uint) {
        //требуют что бы владелец не был 0 адресом
        require(owner != address(0), "owner = zero address");
        //возвращает баланс владельца
        return _balances[owner];
    }
    //функция владельца(принимает индификатор токена) (адрес владельца)
    function ownerOf(uint tokenId) public view override returns (address owner) {
        //владелец равен владельцу финдификатора токена
        owner = _owners[tokenId];
        //требует что бы владелец не был 0 адресом
        require(owner != address(0), "token doesn't exist");
    }
    //функция одобрения для всех(адрес владельца,оператора)возваращает bool
    function isApprovedForAll(address owner, address operator)
        external
        view
        override
        returns (bool)
    {
        //возвращает оператор одобрил
        return _operatorApprovals[owner][operator];
    }
    //функция установить одобрение для всех (адрес оператора, одобрение)
    function setApprovalForAll(address operator, bool approved) external override {
        //оператор оборения владелец оператор = одобрено
        _operatorApprovals[msg.sender][operator] = approved;
        //событие все одобрено(владелец,оператор,одобрено)
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    //функция получения одобрения (индификатор токена)(адрес)
    function getApproved(uint tokenId) external view override returns (address) {
        //требует владелец индифыикатора токена не 0 адрес
        require(_owners[tokenId] != address(0), "token doesn't exist");
        //вернуть токен одобрен и индификатор токена
        return _tokenApprovals[tokenId];
    }
    //функция подтверждения(владелец,куда,индификатор токена)
    function _approve(
        address owner,
        address to,
        uint tokenId
    ) private {
        //токен одобрен по индификатору =  куда
        _tokenApprovals[tokenId] = to;
        //событие одобрено (владелец,куда,индификатор токена)
        emit Approval(owner, to, tokenId);
    }
    //функция утверждения (куда,индификатор токена)
    function approve(address to, uint tokenId) external override {
        //адрес владельца = владельцу индификатора токена
        address owner = _owners[tokenId];
        //требуют владелец == владельцу или владельцу оператору одобрения
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        //одобрено(владельцем,куда,индификатор токена)
        _approve(owner, to, tokenId);
    }
    //функция утверждения владельцем(владелец,покупатель,индификатор токена)
    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) private view returns (bool) {
        //вернуть покупатель== владельц или токенподтверждения == продавец или оператор подтверждения
        return (spender == owner ||
            _tokenApprovals[tokenId] == spender ||
            _operatorApprovals[owner][spender]);
    }
    //функция перевода(владелец,откуда.куда,индификатор токена)
    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        //требовать куда = владельцу
        require(from == owner, "not owner");
        //требовать тчо бы не 0 адрес
        require(to != address(0), "transfer to the zero address");
        //подтверждение (владелец первый адрес,индификатор токена)
        _approve(owner, address(0), tokenId);
        //баланс откуда уменьшается,куда увеличивается, владелец куда
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        //событие перевода токена
        emit Transfer(from, to, tokenId);
    }
    //функция куда переводим(куда,откуда,индификатор токена)
    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        //переодрпеделение владельца = владельцу индификатора токена
        address owner = ownerOf(tokenId);
        //требовать подтевржения владения(владелец,отправитель,индификатор токена)
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        //перевод (владельцу,куда,откуда, индификатор токена)
        _transfer(owner, from, to, tokenId);
    }
    //функция проверки получение на контракт(откуда,куда,индификатор токена,данные) возвр bool
    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private returns (bool) {
        //если куда в контракт
        if (to.isContract()) {
            //вернуть интерфейс куда получено
            //отправителем
            //индификатор токена
            //данные
            //равны итерфейсу контракта принимаеющей функции
            return
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                ) == IERC721Receiver.onERC721Received.selector;
        } else {
            //иначе вернутть правду
            return true;
        }
    }
    //сохранение перевода (владелец,куда,откуда,индификатор токена,данные)
    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        //перевод (владельцу ,куда,откуда,индификатор токена)
        _transfer(owner, from, to, tokenId);
        //требовать проверкиперевода на 721 () "не прием на 721"
        require(_checkOnERC721Received(from, to, tokenId, _data), "not ERC721Receiver");
    }
    //безопасный перевод из(публичный)
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) public override {
        //переопределение владельца
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _safeTransfer(owner, from, to, tokenId, _data);
    }
    //безопасный перевод из(из вне)
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        //переопределение перевода
        safeTransferFrom(from, to, tokenId, "");
    }
    //выпуск монет (куда,индификатор)
    function mint(address to, uint tokenId) external {
        //куда не 0 адрес
        require(to != address(0), "mint to zero address");
        //владелец не 0 адрес
        require(_owners[tokenId] == address(0), "token already minted");
        //баланс +
        //владелец = куда
        _balances[to] += 1;
        _owners[tokenId] = to;
        //событие перевода 
        emit Transfer(address(0), to, tokenId);
    }
    //сжигание
    function burn(uint tokenId) external {
        address owner = ownerOf(tokenId);

        _approve(owner, address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        //событие
        emit Transfer(owner, address(0), tokenId);
    }
}
    //Язык ассемблера, на котором компилируются все контракты Ethereum, 
    //содержит код операции для этой точной операции: EXTCODESIZE. 
    //Этот код операции возвращает размер кода по адресу.
    // Если размер больше нуля, адрес является контрактом
library Address {

    function isContract(address account) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
