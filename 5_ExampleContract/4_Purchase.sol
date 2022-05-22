//Безопасная удаленная покупка

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;
//Purchase покупка
contract Purchase {
    //значение
    uint public value;
    //продавец
    address payable public seller;
    //покупатель
    address payable public buyer;
    //тип даных для перечесления Состояние {Создано, Заблокировано, Выпустить, Неактивно}
    enum State { Created, Locked, Release, Inactive }
    // Переменная состояния имеет значение по умолчанию для первого члена, `State.created`
    State public state;
    //condition - условие 
    modifier condition(bool condition_) {
        //требуют сстояние
        require(condition_);
        _;
    }

    /// Only the buyer can call this function.
    error OnlyBuyer();
    /// Only the seller can call this function.
    error OnlySeller();
    /// The function cannot be called at the current state.
    error InvalidState();
    /// The provided value has to be even.
    error ValueNotEven();
    //модификатор только покупатель
    modifier onlyBuyer() {
        //если (отправитель не покупатель)
        if (msg.sender != buyer)
            //возвращает ошибку OnlyBuyer
            revert OnlyBuyer();
        _;
    }
    //если отправитель не продавец то возвращает ошибку
    modifier onlySeller() {
        if (msg.sender != seller)
            revert OnlySeller();
        _;
    }
    //если состояние сделки не state_ то ошибка
    modifier inState(State state_) {
        if (state != state_)
            revert InvalidState();
        _;
    }
    //события
    event Aborted();//прервано();
    event PurchaseConfirmed();//Покупка подтверждена();
    event ItemReceived();//события получен();
    event SellerRefunded();//Продавец возмещен();

    // Убедитесь, что `msg.value` является четным числом.
    // Деление будет усечено, если это нечетное число.
    // Проверяем с помощью умножения, что это нечетное число.
    // Ensure that `msg.value` is an even number.
    // Division will truncate if it is an odd number.
    // Check via multiplication that it wasn't an odd number.

    //платеж
    constructor() payable {
        //продавец = отправителю
        seller = payable(msg.sender);
        //значение = значение/2
        value = msg.value / 2;
        //если значение*2 не равно значение
        if ((2 * value) != msg.value)
        //вернуть значение ене четное
            revert ValueNotEven();
    }

    // Отменить покупку и вернуть эфир. Может быть вызван только продавцом до контракт заблокирован.
    /// Abort the purchase and reclaim the ether.
    /// Can only be called by the seller before
    /// the contract is locked.
    //функция прерывания(только продавец) в состоянии (состояние. создано)
    function abort()
        external
        onlySeller
        inState(State.Created)
    {
        //состояние Прервано Состояние = Состояние.Неактивно;
        emit Aborted();
        state = State.Inactive;
        // Здесь мы используем передачу напрямую. это безопасно для повторного входа, потому что это
         // последний вызов этой функции и мы уже изменил состояние.
        //продавец.переводит(этому адресу баланс)
        seller.transfer(address(this).balance);
    }

    // Подтвердите покупку как покупатель. Транзакция должна включать `2 * значение` эфира.
    // Эфир будет заблокирован до момента подтверждения Received называется.
    /// Confirm the purchase as buyer.
    /// Transaction has to include `2 * value` ether.
    /// The ether will be locked until confirmReceived
    /// is called.
    //функция подтверждение покупки в состоянии (состояние. создано) условие (значение == (2 * значение))
    function confirmPurchase()
        external
        inState(State.Created)
        condition(msg.value == (2 * value))
        payable
    {
        //событие Покупка подтверждена
        emit PurchaseConfirmed();
        //покупатель=продавец отправитель
        buyer = payable(msg.sender);
        //состояние =заблакировано
        state = State.Locked;
    }

    // Подтвердите, что вы (покупатель) получили товар. Это освободит заблокированный эфир.
    /// Confirm that you (the buyer) received the item.
    /// This will release the locked ether.
    //функция подтверждение получения только для покупателя в состояние заблакировано
    function confirmReceived()
        external
        onlyBuyer
        inState(State.Locked)
    {
        //событие предмет получен
        emit ItemReceived();
        // Важно сначала изменить состояние, потому что
         // в противном случае контракты вызываются с помощью `send` ниже здесь снова можно вызвать.
         //состояние = выпущено
        state = State.Release;
        //перевод покупателя с значением
        buyer.transfer(value);
    }

    // Эта функция возвращает деньги продавцу, т.е.возвращает заблокированные средства продавца.
    /// This function refunds the seller, i.e.
    /// pays back the locked funds of the seller.
    //функция возврат продавцу (только продавцу) состояние выпущено
    function refundSeller()
        external
        onlySeller
        inState(State.Release)
    {
        //событие возврат продавцу
        emit SellerRefunded();
        // Важно сначала изменить состояние, потому что
        // в противном случае контракты вызываются с помощью `send` ниже здесь снова можно вызвать.
        //состояние неактивно
        state = State.Inactive;
        //платеж продавецу 3* значение
        seller.transfer(3 * value);
    }
}