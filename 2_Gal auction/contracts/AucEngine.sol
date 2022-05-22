// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
//галандский аукцион
contract AucEngine {
    //владелец(движка)
    address public owner;
    //сколько длится каждый аукуион
    //constant значениетзадается единожды переопределять нельзя(задается сразу)
    // а immutable можно задать в конструкторе
    uint constant DURATION = 2 days; // days формат sol ковертируется в сек uint
    //сколько забирает площадка
    uint constant FEE = 10; // 10%
    // immutable
    struct Auction {
        //продавец
        address payable seller;
        //стартовая цена(максимальная)
        uint startingPrice;
        //цена за которую продали
        uint finalPrice;
        //когда мы начинаем
        uint startAt;
        //когда заканчиваем
        uint endsAt;
        //на сколько сбрасываем цену за сек
        uint discountRate;
        // то что мы продаем
        string item;
        //закончился или нет?
        bool stopped;
        
    }
    //массив аукцуионов с названием auctions
    Auction[] public auctions;

    //событие после создание аукциона (название длины,строка названия,начальная цена,время)
    //это событие записывается в блокчейн (можем читать из фротенда )
    event AuctionCreated(uint index, string itemName, uint startingPrice, uint duration);
    event AuctionEnded(uint index, uint finalPrice, address winner);
    //
    constructor() {
        //кто развернул,тот владелец
        owner = msg.sender;
    }
    //создание аукциона 
    //_startingPrice сколько создатель хочет получить максимум за товар
    //_discountRate сколько хочет скидывать создатель
    //_item     
    //_duration сколько хотим что бы длился аукцион,если нет то (2 days"по умолчанию")
    function createAuction(uint _startingPrice, uint _discountRate, string memory _item, uint _duration) external {
        //проверка 
        uint duration = _duration == 0 ? DURATION : _duration;
        //проверка что _startingPrice имеет коректное значение
        require(_startingPrice >= _discountRate * duration, "incorrect starting price");
        //memory хнанится в памяти
        //создаем конктретный аукцион
        Auction memory newAuction = Auction({
            //продавец тот кто инициирует транзакцию
            //payable что бы переводит средтва продавцу
            seller: payable(msg.sender),
            //стартавую цену берем из createAuction
            startingPrice: _startingPrice,
            //
            finalPrice: _startingPrice,
            //берем из createAuction
            discountRate: _discountRate,
            //когда начинаем аукцион
            startAt: block.timestamp,
            //время завершение когда начался+сколько длится(будет uint колво сек)
            endsAt: block.timestamp + duration,
            //
            item: _item,
            //изначально не стоп так как мы его только начали
            stopped: false
        });
        //запись аукциона в массив
        auctions.push(newAuction);
        //событие создан новый аукцион
        //(порядковый номаер взять длину массива и вычесть 1,
        //что продаем,изначальная цена,длительность)
        emit AuctionCreated(auctions.length - 1, _item, _startingPrice, duration);
    }
    //фунцкия для цена в конкретный момент времени(при вызове каждый раз разная)
    function getPriceFor(uint index) public view returns(uint) {
        //берем текущий аукцион из массива аукционов
        Auction memory cAuction = auctions[index];
        // вернуть аукцон если он не остановлен
        require(!cAuction.stopped, "stopped!");
        //сколько прошло времени в сек(заданное время - время начала)
        uint elapsed = block.timestamp - cAuction.startAt;
        //сколько нужно скинуть в зависимости от времени
        uint discount = cAuction.discountRate * elapsed;
        // вычесть из начальной цены сколько нужно скинуть
        return cAuction.startingPrice - discount;
    }
    //функция покупки 
    // index что бы узнать на каком аукционе покупаем
    function buy(uint index) external payable {
        //  берем канктретный аукцион по индексу из массива
        Auction storage cAuction = auctions[index];
        //проверка  на то закончен аукцион или нет
        require(!cAuction.stopped, "stopped!");
        //проверка на то закончилось ли время аукциона
        require(block.timestamp < cAuction.endsAt, "ended!");
         //текущая цена (передаем индекс)
        uint cPrice = getPriceFor(index);
        //проверка достаточно ли прислали денег
        require(msg.value >= cPrice, "not enough funds!");
        //если все проверки пройдены то останавливаем аукцион
        cAuction.stopped = true;
        //фиксируем финальную цену аукциона(цена на данный момент)
        cAuction.finalPrice = cPrice;
        //(проверка что денег прислали больше чем нужно)
        //сколько прислали - цена
        //refund - возврат денег
        uint refund = msg.value - cPrice;
        // если refund больше 0 то вернуть количество refund
        if(refund > 0) {
            //покупатель конвектируем в payable и перересылаем колво refund
            payable(msg.sender).transfer(refund);
        }
        //отправляем деньги продавцу
        //аукцион,продавец,транзакция
        //цена - цена - коммисия
        cAuction.seller.transfer(
            cPrice - ((cPrice * FEE) / 100)
        ); // 500
        // 500 - ((500 * 10) / 100) = 500 - 50 = 450
        // Math.floor --> JS
        //событие аукцион закрыт ,индекс,цена,покупатель
        emit AuctionEnded(index, cPrice, msg.sender);
    }
}
