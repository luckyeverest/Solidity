// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC20.sol";

contract ERC20 is IERC20 {
    uint totalTokens;
    address owner;
    mapping(address => uint) balances;  //1 учет сколько у какого адреса токенов
    mapping(address => mapping(address => uint)) allowances;  //2 учет с какого адреса на какой списали
    string _name; //3название
    string _symbol; //4 символ

    function name()override external  view returns(string memory) {
        return _name; //5 считываение название токена и возвращение названия
    }

    function symbol()override external view returns(string memory) {
        return _symbol; // 6 считывание символа
    }
    //13 определяем сколько знаков после запятой
    function decimals()override external pure returns(uint) {
        return 18; // 1 token = 1 wei
    }
    //14 сколько токенов в обороте
    function totalSupply()override external view returns(uint) {
        return totalTokens;
    }
     //7 модификатор что на счету достаточно токенов для перевода
    modifier enoughTokens(address _from, uint _amount) { // откуда и сколько токенов
        require(balanceOf(_from) >= _amount, "not enough tokens!"); //баланс больше количества токенов
        _;
    }
     //8 модификатор ввода токенов, только владелец 
    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!"); //отправитель ==владелец
        _;
    }
    //9 конструктор принимающий имя,символ,сколько токенов изночальновводится в оборот,
    //"магазин для токенов"- что бы владелец в ручную не отправлял токены
    constructor(string memory name_, string memory symbol_, uint initialSupply, address shop) {
        _name = name_; //10 сохнанение переменных
        _symbol = symbol_; //10 сохнанение переменных
        owner = msg.sender; //10 сохнанение переменных
        mint(initialSupply, shop); //11 чеканка монет(ввод в оборот монет)
    }
    //15 обращаеся к mapping balances и считаем баланс для конректоно адреса
    function balanceOf(address account)override public view returns(uint) {
        return balances[account];
    }
    //16 с кошелька инициатора на другой 
    function transfer(address to, uint amount)override external enoughTokens(msg.sender, amount) {
        _beforeTokenTransfer(msg.sender, to, amount);//21 проверка 
        balances[msg.sender] -= amount;//17 наш баланс уменьшается на количество перевода
        balances[to] += amount;//18 его баланс увеличится на колво перевода
        emit Transfer(msg.sender, to, amount);//19 событие кто отправил,кому,сколько
    }
     //12 ввод токенов в оборот, принимает сколько и куда вводим
    function mint(uint amount, address shop) public onlyOwner {
        _beforeTokenTransfer(address(0), shop, amount);//21 проверка
        balances[shop] += amount;
        totalTokens += amount; //сколько токенов выпущено на данный момент
        emit Transfer(address(0), shop, amount);//0 //адрес потому что мы только их создали,создатель магазин,сколько забрал
    }
    //35 вывод токенов из обората,принимает адрес с которого сжигают токены и сколько
    function burn(address _from, uint amount) public onlyOwner {//36 только владелец 
        _beforeTokenTransfer(_from, address(0), amount);//37 списываем токены на 0 адрес
        balances[_from] -= amount;//38 баланс уменьшатеся на колво
        totalTokens -= amount;//39 общее колво токенов уменьшается на колво
    }
    //22 проверка может ли стороний адрес списать средства,принимает 
    function allowance(address _owner, address spender)override public view returns(uint) {
        return allowances[_owner][spender];//23 обращение к mapping allowances
    }
    //24 проверка,принимает кому и сколько мы разрешаем перевести
    function approve(address spender, uint amount)override public {
        _approve(msg.sender, spender, amount);//
    }
    //25 создание служебной функции
    function _approve(address sender, address spender, uint amount) internal virtual {
        allowances[sender][spender] = amount;//26 отправитель тратющий сколько
        emit Approve(sender, spender, amount);//27 событие отправитель тратющий сколько
    }
    //28 забирает с отправителя в пользу получателя
    function transferFrom(address sender, address recipient, uint amount)override public enoughTokens(sender, amount) {
        _beforeTokenTransfer(sender, recipient, amount);//29 проверка 
         //require(allowances[sender][recipient] >= amount, "check allowance!");31 проверка что запрос >= суммы
        allowances[sender][recipient] -= amount;  //30 если запрос больше того что мы разрешили списать то error! 

        balances[sender] -= amount;//32 у отправителя вычитаем
        balances[recipient] += amount;//33 у получателя прибавляем
        emit Transfer(sender, recipient, amount);//34 событие 
    }
    //20 "opnezepplin" перед переводом провести какуето операцию 
    function _beforeTokenTransfer(
        address from,//кто 
        address to,//кому
        uint amount//сколько
    ) internal virtual {}
}
//40 наследуемый контракт от ERC20 принимает адрес магазина
contract GRIBToken is ERC20 {

    //41 передаем название, символ, колво,адрес магазина 
    constructor(address shop) ERC20("GRIBToken", "GRIB", 1000, shop) {}
}
//42 контракт магазина
contract GRIBShop {
    //43 пишим адрес токена, но вместо adress пишим IERC20 
    //делаея его объектом который отображает интерфейс
    IERC20 public token;
    //44 адрес владельца магазина payable что бы переводит средства
    address payable public owner;
    //45 событие купил сколько и кто
    event Bought(uint _amount, address indexed _buyer);
    //46 событие продал сколько и кто
    event Sold(uint _amount, address indexed _seller);

    constructor() {
        //47 операция развертывания сторонего смарт контракта
        //в него передаем адрес магазина в котором реальзоваем токен
        token = new GRIBToken(address(this));
        //48 владелец есть отправитель 
        owner = payable(msg.sender);
    }
    //49 модификатор ввода токенов, только владелец
    modifier onlyOwner() {
        require(msg.sender == owner, "not an owner!");
        _;
    }
    //56 (сколько)
    function sell(uint _amountToSell) external {
        require(
            //57 продать меньше 0 токенов нельзя И
            _amountToSell > 0 &&
            //58 клиет не мог продать токенов больше чем у него на счету
            token.balanceOf(msg.sender) >= _amountToSell,
            "incorrect amount!"
        );
        //59 проверяем было ли дано разрешение на продажу(владелец кошелька,сам магазин)
        uint allowance = token.allowance(msg.sender, address(this));
        //60 allowance разрешеное коливо токенов больше или равно коливу продажи
        require(allowance >= _amountToSell, "check allowance!");
        //61 перевод владельца , адрес магазина,колво
        token.transferFrom(msg.sender, address(this), _amountToSell);
        //62 начисляем продающему (если курс не в wei то пересчитываем)
        payable(msg.sender).transfer(_amountToSell);
        //63 событие что продали (сколько ,кто)
        emit Sold(_amountToSell, msg.sender);
    }
// 50 клиеты будут покупать себе токены (вызывается автоматически если на контракт )
//пришли деньги
    receive() external payable {
        //51 токен для продажи стоит 1 wei(если стоимость другая
        //то надо пересчитать курс)
        uint tokensToBuy = msg.value; // 1 wei = 1 token
        //52 0 токенов купить нельзя
        require(tokensToBuy > 0, "not enough funds!");
        //53 сколько вообще токенов на продажу
        require(tokenBalance() >= tokensToBuy, "not enough tokens!");
        //54 обращение к объекту токен (кому"тото кто переревел деньги",сколько)
        token.transfer(msg.sender, tokensToBuy);
        //55 событие (сколько кто)
        emit Bought(tokensToBuy, msg.sender);
    }
    //64 сколько на счету магазина
    function tokenBalance() public view returns(uint) {
        //65 смотрим баланс на текущем адресе
        return token.balanceOf(address(this));
    }
}