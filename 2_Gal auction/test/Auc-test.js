//импорт библеотек
const { expect } = require("chai") //ожидание
const { ethers } = require("hardhat") //что бы рабоатать из вне

//describe групперовать тесты (по функциям ,контрактом ,фичи)
describe("AucEngine", function() {
    //обявляем переменные которые понадобится в тестах
    let owner //владелец
    let seller //продавец
    let buyer //покупатель
    let auct //аукцион
        //перед каждым тестом будет разворачиватся асинхроную функцию
    beforeEach(async function() {
            //владелец,продавец,покупатель из массива котрый возвращает getSigners
            [owner, seller, buyer] = await ethers.getSigners()
                //переменая AucEngine получает данные скомпилированой версии конракта
                //адрес владельца
            const AucEngine = await ethers.getContractFactory("AucEngine", owner)
                //ждем AucEngine
            auct = await AucEngine.deploy()
                //разворачиваем аукцион
            await auct.deployed()
        })
        //it описыват конктретный тест(тиестируем кусочек функционала)
        //после развертывания установлен коректный владелец
    it("sets owner", async function() {
            //создаем переменую currentOwner которой присваиваем значение владельца аукциона
            const currentOwner = await auct.owner()
                //проверяем что currentOwner (равен .to.eq) адресу владельца
            expect(currentOwner).to.eq(owner.address)
                //просто вывод 
                //console.log(currentOwner)
        })
        //сломаный тест (владелец не продавец)
        // it("NO owner", async function() {
        //     const currentOwner = await auct.owner()
        //     expect(currentOwner).to.eq(seller.address)
        //         //console.log(currentOwner)
        // })

    //считывание из блокчейна даты/время для тестирования
    //
    async function getTimestamp(bn) {
        return (
            //черещ ethers js подклбючаемся к блокчейну 
            //getBlock - позволяет получить информацию о люьбом блоке в этом блокчейне
            await ethers.provider.getBlock(bn)
            //получить дату можно по атрибуту timestamp
        ).timestamp
    }
    //в глобальном describe создаем локальный describe описывающий функцию createAuction
    //просто для логической групперовки
    describe("createAuction", function() {
            // проверка на коректный аукцион(creates auction correctly - описание)
            //писать описанрие надо понятным что бы понимать что тестируем
            it("creates auction correctly", async function() {
                // переменая сколько длится аукцион
                const duration = 60
                    // создание аукциона через транзакцию
                    // используемauct объект с описаными функциями смарт конракта
                    //проверяем что функция сохраняет правельные переменные 
                const tx = await auct.createAuction(
                        //за сколько мы хотяим продвать товар
                        //ethers.utils.parseEther утилита ethers js для конвертирования eth в wei
                        ethers.utils.parseEther("0.0001"),
                        //сколько будет сбрасывать в секунду wei
                        3,
                        //название предмета продажи
                        "fake item",
                        //время
                        duration
                    )
                    // достаем инф о текущем аукционе из блокчену 
                    //обращаемся к массиву аукционов и дастаем первый под индексом 0
                const cAuction = await auct.auctions(0) // надо писать await иначе вернет Promise 
                    //вывод
                    //console.log(cAuction)
                    //проверка на то item равен названию fake item
                expect(cAuction.item).to.eq("fake item")
                    //использование функции getTimestamp объявленой раниее
                    //название ts от timestamp
                    //и передаем номер блока tx.blockNumber
                const ts = await getTimestamp(tx.blockNumber)
                    //проверяем что созданый аукцион cAuction имеет правельную дату конца endsAt
                    //ts метка врмени + duration (сколько длится аукцион)
                expect(cAuction.endsAt).to.eq(ts + duration)
                    //console.log(tx)
            })
        })
        //функция что бы что то ждать delay задерживать
    function delay(ms) {
        // возвращает промис который дает разрешение 
        return new Promise(resolve => setTimeout(resolve, ms))
    }
    //allows to buy  позволяет купить

    describe("buy", function() {
        it("allows to buy", async function() {
            //!надо помнить что на начало каждого тестирования нет смарт конракта и его надо разворачивать
            // создаем начальные данные в тесте ,напримере createAuction(пререквезиты)
            await auct.connect(seller).createAuction(
                    ethers.utils.parseEther("0.0001"),
                    3,
                    "fake item",
                    60
                )
                //для ожидания выполнения (что бы мокка не вылетела)
                //this указывает на тест ,timeout что тест может выпонятся до 5 сек 
            this.timeout(5000) // 5s
                //ждем 1 сек прежде чем приступать к выполнению теста
            await delay(1000)
                //buyTx транзакция покупки берем аукцион 
                //берем другой аккаунт buyer (покупатель)(что бы тразакция не проходитла от owner"по умолчанию"")
            const buyTx = await auct.connect(buyer).
                //buy(купить) 0- индекс аукциона 
                //value сумма покупки 
            buy(0, { value: ethers.utils.parseEther("0.0001") })
                //считывает инф о аукционе после того как купили ,для проверки changeEtherBalance
            const cAuction = await auct.auctions(0)
                //создаем переменую и присваиваем ей финальную цену
            const finalPrice = cAuction.finalPrice
                //передаем в ананимную функцию нашу транзакцию buyTx
                //
            await expect(() => buyTx).
                //changeEtherBalance проверка от waffle спецефичная для бокчейна
            to.changeEtherBalance(
                    //сколько денег должно оказатся на счету продавца
                    //продавец ,должен получить финальная цена минус коммисия
                    //Math.floor /получаем значение как в солидити (не откидывая дробную часть)
                    seller, finalPrice - Math.floor((finalPrice * 10) / 100)
                )
                //порверка waffle на пораждение события
                //buyTx транзакция, событие аукциона auct,
            await expect(buyTx)
                .to.emit(auct, 'AuctionEnded')
                //индекс,цена,отправитель
                .withArgs(0, finalPrice, buyer.address)
                //проверка что после завешения аукциона нельзя купить еще раз товар
            await expect(
                auct.connect(buyer).buy(0, { value: ethers.utils.parseEther("0.0001") })
            ).to.be.revertedWith('stopped!')
        })
    })
})