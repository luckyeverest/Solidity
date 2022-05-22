// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
contract SimpleAuction {
// Параметры аукциона. Время либо абсолютные временные метки
// unix (секунды с 1970-01-01) или периоды времени в секундах.
//beneficiary получатель(payable платежная)
    address payable public beneficiary;
    //auctionEndTime -время окончания аукциона
    uint public auctionEndTime;

    // Текущее состояние аукциона.
    //адрес highestBidder-наивысшая ставка
    address public highestBidder;
    //число самая высокая ставка
    uint public highestBid;

    // Разрешен отзыв предыдущих ставок массив pendingReturns -ожидающие возвраты
    mapping(address => uint) pendingReturns;
    // В конце установить значение true, запрещает любые изменения.
    // По умолчанию инициализировано значением false.
    bool ended;

    // События, которые будут сгенерированы при изменении.
    // событие HighestBidIncreased Увеличена самая высокая ставка(адрес-участник торгов,колво)
    event HighestBidIncreased(address bidder, uint amount);
    // АукционЗавершен(адрес победителя, колво)
    event AuctionEnded(address winner, uint amount);

    // Ошибки, описывающие сбои.

    // Комментарии с тройной косой чертой — это так называемые natspec
     // Комментарии. Они будут показаны, когда пользователь
     // запрашивается подтверждение транзакции или когда отображается ошибка.

    // Аукцион уже закончился.
    /// The auction has already ended.
    error AuctionAlreadyEnded();

    // Уже есть более высокая или равная ставка.
    /// There is already a higher or equal bid.
    //Ставка недостаточно высока(самая высокая ставка)
    error BidNotHighEnough(uint highestBid);

    // Аукцион еще не закончился.
    /// The auction has not ended yet.
    error AuctionNotYetEnded();

    // Функция аукциона Конец уже была вызвана.
    /// The function auctionEnd has already been called.
    error AuctionEndAlreadyCalled();

    /// Create a simple auction with `biddingTime`
    /// seconds bidding time on behalf of the
    /// beneficiary address `beneficiaryAddress`.
    // Создаем простой аукцион с параметром `biddingTime`
    // секунды время торгов от имени адрес получателя `beneficiaryAddress`.
    constructor(
        //время торгов
        uint biddingTime,
        //адрес платежный получатель
        address payable beneficiaryAddress
    ) {
        //получатель = адрес получателя
        beneficiary = beneficiaryAddress;
        //время конца аукциона = временя метка + время торгов
        auctionEndTime = block.timestamp + biddingTime;
    }

    /// Bid on the auction with the value sent
    /// together with this transaction.
    /// The value will only be refunded if the
    /// auction is not won.
    // Ставка на аукционе с отправленным значением вместе с этой транзакцией.
    // Значение будет возвращено только в том случае, если аукцион не выигран.
    //bid -делать ставку
    function bid() external payable {
        // Аргументы не нужны, все информация уже является частью
        // перевод. payable требуется, чтобы функция иметь возможность получать эфир.

        // Отменить вызов, если торги период закончился.
        //если (врменая метка >время конца аукциона)
        if (block.timestamp > auctionEndTime)
        //revert-отменить Аукцион уже завершен
            revert AuctionAlreadyEnded();
        // Если ставка не выше, отправляем возврат денег (оператор возврата
        // отменит все изменения в этом выполнение функции, включая он получил деньги).

        //если(значение больше или равно самая высокая ставка)
        if (msg.value <= highestBid)
        //отменить Ставка недостаточно высока(самая высокая ставка)
            revert BidNotHighEnough(highestBid);

        //если (самая высокая ставка не равна 0)
        if (highestBid != 0) {
            // Отправляем деньги, просто используя
             // highBidder.send(highestBid) представляет угрозу безопасности
             // потому что он может выполнить ненадежный контракт.
             // Всегда безопаснее позволить получателям снять свои деньги сами.
             //ожидающие возвраты[наивысшая ставка]+=самая высокая ставка
            pendingReturns[highestBidder] += highestBid;
        }
        //наивысшая ставка = отправитель
        highestBidder = msg.sender;
        //самая высокая ставка = значению
        highestBid = msg.value;
        //событие Увеличена самая высокая ставка(отправитель, значение)
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    // Отозвать ставку, которая была перебита.
    /// Withdraw a bid that was overbid.
    //withdraw - изымать ,возращаем булево значение
    function withdraw() external returns (bool) {
        //количество = ожидающие возвраты[отправитель]
        uint amount = pendingReturns[msg.sender];
        //если колво > 0 
        if (amount > 0) {
            // Важно установить это значение равным нулю, потому что получатель
            // можно снова вызвать эту функцию как часть принимающего вызова перед возвратом `send`.
            //ожидающей возвраты[отправитель]=0
            pendingReturns[msg.sender] = 0;

            // msg.sender не имеет типа «адрес к оплате» и должен быть
            // явно преобразовано с помощью `payable(msg.sender)` для того, 
            //чтобы используем функцию-член `send()`.
            //если(платежная(отправитель)Отправить(количество))
            if (!payable(msg.sender).send(amount)) {
                // Здесь не нужно вызывать throw, просто сбрасываем причитающуюся сумму
                //ожидающие отправителя[отправитель]= колво
                pendingReturns[msg.sender] = amount;
                //вернуть неправда
                return false;
            }
        }
        //иначе правда
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    // Завершить аукцион и отправить самую высокую ставку получателю

    function auctionEnd() external {
// Это хорошее руководство по структурированию взаимодействующих функций
         // с другими контрактами (т.е. они вызывают функции или отправляют эфир)
         // на три фазы:
         // 1. проверка условий
         // 2. выполнение действий (возможно изменение условий)
         // 3. взаимодействие с другими контрактами
         // Если эти фазы перепутаны, другой контракт может вызвать
         // вернуться к текущему контракту и изменить состояние или причину
         // эффекты (выплата эфира) должны выполняться несколько раз.
         // Если функции, вызываемые внутри, включают взаимодействие с внешними
         // контракты, они также должны учитывать взаимодействие с внешние контракты.

        // 1. Условия
        //если(временая метка < время конца аукциона)
        if (block.timestamp < auctionEndTime)
            //возвращаться АукционЕщеНеЗавершен
            revert AuctionNotYetEnded();
        //если (закончился)
        if (ended)
        //возвращается Окончание аукциона уже объявлено
            revert AuctionEndAlreadyCalled();

        // 2. Последствия
        //конец = правда
        ended = true;
        //событие аукцион закончен(самую высокую цену,самая высокая ставка)
        emit AuctionEnded(highestBidder, highestBid);

        // 3. Взаимодействие
        //получатель.перевод(самая высокая ставка)
        beneficiary.transfer(highestBid);
    }
}