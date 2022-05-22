/*
Свод
Простой пример контракта хранилища, обычно используемого в протоколах DeFi.

Большинство хранилищ в основной сети более сложные. Здесь мы сосредоточимся на математике для расчета акций, которые нужно отчеканить при депозите, и количества токенов для вывода.

Как работает контракт
Некоторое количество акций чеканится, когда пользователь вносит депозит.
Протокол DeFi будет использовать депозиты пользователей для получения дохода (каким-то образом).
Пользователь сжигает акции, чтобы вывести свои токены + доход.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Vault {
    IERC20 public immutable token;

    uint public totalSupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }

    function deposit(uint _amount) external {
        /*
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint

        (T + s) / T = (a + B) / B 

        s = aT / B
        */
        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / token.balanceOf(address(this));
        }

        _mint(msg.sender, shares);
        token.transferFrom(msg.sender, address(this), _amount);
    }

    function withdraw(uint _shares) external {
       /*
         а = количество
         B = баланс токена перед выводом
         T = общее предложение
         s = акции для сжигания

         (Т - с) / Т = (В - а) / В

         а = sВ/Т
         */
        uint amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
}
