// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
//BlindAuction-слепой аукцион
contract BlindAuction {
    //bid Делать ставку
    struct Bid {
        //слепая ставка
        bytes32 blindedBid;
        //deposit-Деньги или ценные бумаги, вносимые в кредитное учреждение
        // для хранения или со специальной целью.
        uint deposit;
    }
    //beneficiary получатель платежный адрес
    address payable public beneficiary;
    //конец торгов
    uint public biddingEnd;
    //показать конец
    uint public revealEnd;
    //законченно
    bool public ended;

    //массив адресов ставок с название bids - ставки
    mapping(address => Bid[]) public bids;

    //адрес наивысшей ставки
    address public highestBidder;
    //число самой высокой ставки
    uint public highestBid;

    // Разрешен отзыв предыдущих ставок
    //массив адресов ожидающие возвраты
    mapping(address => uint) pendingReturns;
    //событие аукцион закончен (адрес победителя,самая высокая ставка)
    event AuctionEnded(address winner, uint highestBid);

    // Ошибки, описывающие сбои.

    // Функция была вызвана TooEarly-слишком рано. Повторить попытку в `время`.
    /// The function has been called too early. Try again at `time`.
    error TooEarly(uint time);
    // Функция была вызвана TooLate - слишком поздно. Его нельзя вызывать после `time
    /// The function has been called too late. It cannot be called after `time`.
    error TooLate(uint time);
    // Функция аукциона Конец уже была вызвана.
    /// The function auctionEnd has already been called.
    error AuctionEndAlreadyCalled();

    // Модификаторы — это удобный способ проверки входных данных для функции.
    // `onlyBefore` применяется к `bid` ниже:
    // Тело новой функции — это тело модификатора, где `_` заменяется старым телом функции
    //onlyBefore - только до (передаем время)
    modifier onlyBefore(uint time) {
        //если(временая метка >= времени)вернуть слишком поздно (время)
        if (block.timestamp >= time) revert TooLate(time);
        //`_` заменяется старым телом функции
        _;
    }
    //onlyAfter - только после(передаем время)
    modifier onlyAfter(uint time) {
        //если(вр.метка <= времени) возвращаем Слишком рано(время)
        if (block.timestamp <= time) revert TooEarly(time);
                //`_` заменяется старым телом функции
        _;
    }

    constructor(
        //время торгов
        uint biddingTime,
        //показать время
        uint revealTime,
        //платежный адрес получателя 
        address payable beneficiaryAddress
    ) {
        //получатель = адресПолучателя
        beneficiary = beneficiaryAddress;
        //Конец торгов = вр.метка + время торгов
        biddingEnd = block.timestamp + biddingTime;
        //показать время = конец торгов + показать время
        revealEnd = biddingEnd + revealTime;
    }

    // Разместите слепую ставку с помощью `blindedBid` =keccak256(abi.encodePacked(value, fake, secret)).
    // Отправленный эфир возвращается только в случае правильной ставки
    // раскрывается на этапе выявления. Ставка действительна, если
    // эфир, отправляемый вместе с ставкой, не ниже "значения" и
    // "подделка" не соответствует действительности. Установка «fake» в true и отправка
    // не точная сумма - это способы скрыть реальную ставку, но
    // по-прежнему внести требуемый депозит. Этот же адрес может делаем несколько ставок.
    /// Place a blinded bid with `blindedBid` =
    /// keccak256(abi.encodePacked(value, fake, secret)).
    /// The sent ether is only refunded if the bid is correctly
    /// revealed in the revealing phase. The bid is valid if the
    /// ether sent together with the bid is at least "value" and
    /// "fake" is not true. Setting "fake" to true and sending
    /// not the exact amount are ways to hide the real bid but
    /// still make the required deposit. The same address can
    /// place multiple bids.
    //bid Делать ставку(слепая ставка)
    function bid(bytes32 blindedBid)
        external
        payable
        ///только до(конца торгов)
        onlyBefore(biddingEnd)
    {
        //ставка[отправителя] записывается в ставку
        bids[msg.sender].push(Bid({
            //ключ слепая ставка,значение слепая ставка
            blindedBid: blindedBid,
            //значение депозита
            deposit: msg.value
        }));
    }

    // Покажите свои слепые ставки. Вы получите возврат за все
    // правильно ослепил недействительные ставки и по всем ставкам кроме самый высокий.
    /// Reveal your blinded bids. You will get a refund for all
    /// correctly blinded invalid bids and for all bids except for
    /// the totally highest.
    //reveal-раскрывать
    function reveal(//передаем в функцию значения calldate
        //calldata(специальное расположение данных, содержащее аргументы функции,
        // доступное только для параметров вызова внешней функции)
        //значение
        uint[] calldata values,
        //подделки
        bool[] calldata fakes,
        //секреты
        bytes32[] calldata secrets
    )
        external
        onlyAfter(biddingEnd)///толькоПосле(конеца торгов)
        onlyBefore(revealEnd)///толькоперед(раскрытого конеца)
    {
        //длина = ставказ[отправителя]длина
        uint length = bids[msg.sender].length;
        //значение длины равно длиене
        require(values.length == length);
        //значение поддделок равно длиене
        require(fakes.length == length);
        //значение секретов равно длиене
        require(secrets.length == length);

        //refund возвращать деньги
        uint refund;
        //для условий
        for (uint i = 0; i < length; i++) {
            //ставки из хронилища = отправителю ставок
            Bid storage bidToCheck = bids[msg.sender][i];
            //значение,подделки,секреты равны
            (uint value, bool fake, bytes32 secret) =
                    //по идексу
                    (values[i], fakes[i], secrets[i]);
            //если (проверка слепой ставки) не равна хешированому (значению,подделки,секрету)
            if (bidToCheck.blindedBid != keccak256(abi.encodePacked(value, fake, secret))) {
                // (Ставка фактически не была раскрыта. Не возвращать депозит)
                //продолжаем
                continue;
            }
            //возвращаем деньги += депозит проверки слепой ставики
            refund += bidToCheck.deposit;
            //если (подделка и депозит проверки ставки) >= значению
            if (!fake && bidToCheck.deposit >= value) {
                //если (место ставку (значение отправителя))
                if (placeBid(msg.sender, value))
                    //вернуть значение денег
                    refund -= value;
            }
            // Сделать невозможным повторное получение отправителем того же депозита.
            //проверка слепой ставки рано 0 
            bidToCheck.blindedBid = bytes32(0);
        }
        //отправителю отправляем refund
        payable(msg.sender).transfer(refund);
    }
    // Отозвать ставку, которая была перебита.
    /// Withdraw a bid that was overbid.
    //withdraw - изымать
    function withdraw() external {
        //количество = ожиданию возвравта отправителя
        uint amount = pendingReturns[msg.sender];
        //если колво>0
        if (amount > 0) {
            // Важно установить это значение равным нулю, потому что получатель
             // можно снова вызвать эту функцию как часть принимающего вызова
             // перед возвратом `transfer` (см. примечание выше о условия -> эффекты -> взаимодействие).
             //одидание возврата равно нулю
            pendingReturns[msg.sender] = 0;
            // отправителю отправляем колво
            payable(msg.sender).transfer(amount);
        }
    }
    // Завершить аукцион и отправить бенефициару самую высокую ставку.
    /// End the auction and send the highest bid
    /// to the beneficiary.
    //аукцион завершен
    function auctionEnd()
        external
        onlyAfter(revealEnd)///только после раскрытого конца
    {
        //если конец возвращаем конец аукциона
        if (ended) revert AuctionEndAlreadyCalled();
        //создаем событие аукцион закончен(адрес самой высокой ставки,яисло ставки)
        emit AuctionEnded(highestBidder, highestBid);
        //конец меняем на правду
        ended = true;
        //отрпавтелю отправляем деньги
        beneficiary.transfer(highestBid);
    }
    //placeBid-место ставки(участник торгов,значение)
    function placeBid(address bidder, uint value) internal
            returns (bool success)///успех
    {
        //если(значение <=самая высокая ставка)
        if (value <= highestBid) {
            //вернуть лож
            return false;
        }
        //если наивысшая ставка не равна адресу
        if (highestBidder != address(0)) {
            //ожидающие возврата[наивысшая ставка] += самая высокая ставка
            pendingReturns[highestBidder] += highestBid;
        }
        //самая высокая ставка= значению
        highestBid = value;
        //наивысшая ставка = участник торгов
        highestBidder = bidder;
        //правда
        return true;
    }
}