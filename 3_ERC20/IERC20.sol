// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// интерфейс для работы из вне
interface IERC20 {
    //-------------------для отоброжения не часть стандарта
    //название токена
    function name() external view returns(string memory);
    //краткое наименование токена
    function symbol() external view returns(string memory);
    //сколько знаков после запятой  
    function decimals() external pure returns(uint); // 0
    //-------------------
    //сколько токенов в обороте
    function totalSupply() external view returns(uint);
    //проверка баланса ,принимает адрес аккаунта для проверки баланса
    function balanceOf(address account) external view returns(uint);
    // перевод , принимает адрес куда переводим и кол-во
    function transfer(address to, uint amount) external;
    //позволяет забрать токены с контракта в пользу третьего лица,принимает владелца и кто может это сделать
    function allowance(address _owner, address spender) external view returns(uint);
    //потверждение ,принимает кто и сколько забрать через 
    function approve(address spender, uint amount) external;
    //перевод списываение ,принимает откуда ,куд, сколько
    function transferFrom(address sender, address recipient, uint amount) external;
    //событие перевода,откуда,куда,сколько *indexed позваоляет потом делать поиск
    event Transfer(address indexed from, address indexed to, uint amount);
    // потверждение что можно списывать средства, владелец,адрес куда,сколько
    event Approve(address indexed owner, address indexed to, uint amount);
}