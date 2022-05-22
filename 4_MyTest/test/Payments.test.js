//импорт библиотек
const { expect } = require("chai")
const { ethers } = require("hardhat")

//описываем смарт контракт Payments и в function будем писать сами тесты
//что бы тестировтаь надо развернуть контракт в блокчейне(тест сети)
//разварачиваем в hardhat
describe("Payments", function() {
    // обявляем переменые аккаунта
    let acc1
    let acc2
        //
    let payments
        //перед каждым тестом будет разворачиватся асинхроную функцию 
    beforeEach(async function() {
            //получение тестовых аккаунтов hardhat 
            //Signers аккаунт
            //[acc1, acc2] два аккаунта из массива котрый возвращает getSigners
            [acc1, acc2] = await ethers.getSigners()
                // ethers.getContractFactory получение информации о скомпилированой версии смартконтракта 
                //с названием Payments ,разворачивается от имени acc1
            const Payments = await ethers.getContractFactory("Payments", acc1)
                // в переменой payments сохраним спец обект с помощью которого будем взаимодействовать 
                // смарт конрактом
            payments = await Payments.deploy() //ждем пока транзакция будет отправлена  
            await payments.deployed() // ждем пока она будет выполнена
                //выводим адрес развернутого конракта
            console.log(payments.address)
        })
        //it открывает тест
        //перед каждым тестом будет выполнятся блок beforeEach
        //все тесты должны быть изолированы
    it("should be deployed", async function() {
            //проверяем что адрес развернутого контракта коректный
            //заходим в документацию waflle 
            //находим проверку на адрес и копируем
            //и подставляем переменую (адрус конракта)в проверку
            //npx hardhat test запустить проверку
            expect(payments.address).to.be.properAddress
        })
        //проверка что баланс изначально 0
    it("should have 0 ether by default", async function() {
            //вызываем фунцию currentBalance
            //await асинхроная функция потому что она не мгновенная
            const balance = await payments.currentBalance()
                //вывод значения
            console.log(balance)
                //сама проверка, eq равно 
            expect(balance).to.eq(0)
        })
        //отправка денежных средств с помощью транзакции
    it("should be possible to send funds", async function() {
        //заводим переменую суммы для использования в качестве шаблона (для удобства)
        const sum = 100
        const msg = "hello from hardhat"
            //создание переменой транзакция название tx 
            //берем переменую из payments 
            //connect позволяет уставить адрес аккаунта,если его нет то транзакция отправится с первого
            //аккаунта
        const tx = await payments.connect(acc2).pay(msg, { value: sum })
            // проверяем что колво денежных средств меняется при запуске транзакции
            //в expect передаемфункцию транзакцию 
        await expect(() => tx)
            //указываем где должен поменятся баланс эфиров на счетах
            //на аккаунте acc2 должно стать меньше ,а на адресе смартконтракта больше
            .to.changeEtherBalances([acc2, payments], [-sum, sum]);
        //ждем завершение транзакции 
        await tx.wait()
            //получить информацию о конкретном платеже getPayment (адрес откуда и индекс номер платежа)
        const newPayment = await payments.getPayment(acc2.address, 0)
            //вывод информации 
        console.log(newPayment)
            //проверка сообщения из конкретного платежа
        expect(newPayment.message).to.eq(msg)
            //баланса
        expect(newPayment.amount).to.eq(sum)
            //адреса
        expect(newPayment.from).to.eq(acc2.address)
    })
})