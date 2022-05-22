// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
/// @title Voting with delegation.
contract Ballot {//билютень
    // Это объявляет новый сложный тип, который будет использоваться для переменных позже.
    // Он будет представлять одного избирателя.
    struct Voter {//избиратель
        uint weight;//вес накапливается делегированием
        bool voted; //voted-проголосовал если правда, этот человек уже проголосовал
        address delegate;// лицо, делегированное
        uint vote; //vote-голосование индекс проголосовавшего предложения
    }

    // Это тип для одного Proposal- предложения.
    struct Proposal {
        bytes32 name;// имя не больше 32 байт
        uint voteCount; // количество набранных голосов
    }
    //chairperson-председатель
    address public chairperson;
    // Это объявляет переменную состояния, которая
    // сохраняет структуру массив `Voter`-избиратель для каждого возможного адреса.
    mapping(address => Voter) public voters;

    // динамический массив структур `Proposal`-предложения
    Proposal[] public proposals;

    /// Create a new ballot to choose one of `proposalNames`.
    // Создать новый бюллетень для выбора одного из `proposalNames`- название предложения
    //Массив примеров для конструктора
    //["0x50726f706f73616c204100000000000000000000000000000000000000000000", 
    //"0x50726f706f73616c204200000000000000000000000000000000000000000000",
    //"0x50726f706f73616c204300000000000000000000000000000000000000000000"]
    constructor(bytes32[] memory proposalNames) {
        //председатель = отправитель
        chairperson = msg.sender;
        //из массива избирателей берем председателя = 1;
        voters[chairperson].weight = 1;

        // Для каждого из предоставленных названий предложений
        // создаем новый объект предложения и добавляем его в конец массива.
        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})` создает временный
             // Объект предложения и `proposals.push(...)`
             // добавляет его в конец `proposals`.
            proposals.push(Proposal({
                //имя: предложенияИмена[i],
                name: proposalNames[i],
                //количество голосов
                voteCount: 0
            }));
        }
    }
    // Предоставить `избирателю` право голосовать в этом бюллетене.
    // Может вызываться только `председателем`.
    //giveRightToVote - датьПравоГолосовать ,voter избиратель
    function giveRightToVote(address voter) external {
        // Если первый аргумент `require` оценивается в `false` выполнение прекращается и все
         // изменения состояния и баланса эфира возвращаются.
         // Это использовалось для потребления всего газа в старых версиях EVM, но уже нет.
         // Часто рекомендуется использовать `require`, чтобы проверить, функции вызываются правильно.
         // В качестве второго аргумента вы также можете указать объяснение того, что пошло не так.
        require(//требовать
            //отправитель == председатель
            msg.sender == chairperson,
            //Только председатель может дать право голоса
            "Only chairperson can give right to vote."
        );
        require(//требовать
            //избиратели [избиратель]. проголосовал
            !voters[voter].voted,
            //Избиратель уже проголосовал.
            "The voter already voted."
        );
        //требовать избиратели[избиратель].вес
        require(voters[voter].weight == 0);
        //избиратели[избиратель].вес
        voters[voter].weight = 1;
    }

    /// Delegate your vote to the voter `to`.
    // Делегируйте свой голос избирателю `to`.
    //delegate делегировать
    function delegate(address to) external {
        // присваивает ссылку
        //Отправитель  избирателей = избиратели[отправитель]
        Voter storage sender = voters[msg.sender];
        //отправитель. проголосовал, «Вы уже проголосовали»
        require(!sender.voted, "You already voted.");
        //to != отправитель , "Самоделегирование запрещено.");
        require(to != msg.sender, "Self-delegation is disallowed.");

        // Пересылать делегирование до тех пор, пока `to` также делегируется.
         // Вообще такие циклы очень опасны,потому что, если они будут работать слишком долго, они могут
         // потратить нужно больше газа, чем доступно в блоке.
         // В этом случае делегирование выполнено не будет,но в других ситуациях такие циклы могут
         // заставить контракт полностью "зависнуть".
         //в то время как (избиратели [к]. делегат! = адрес 
        while (voters[to].delegate != address(0)) {
            //к = избиратели[к].delegate;
            to = voters[to].delegate;

            // Нашли петлю в делегировании, не допустили.
            //к != sender , "Обнаружена петля в делегировании".
            require(to != msg.sender, "Found loop in delegation.");
        }

        // Так как `sender` является ссылкой, это изменяет `избиратели[отправитель].проголосовал`
        //Делегат хранения избирателей_ = избиратели[кому]
        Voter storage delegate_ = voters[to];

        // Избиратели не могут делегировать кошельки, которые не могут голосовать.
        //делегат_.вес >= 1
        require(delegate_.weight >= 1);
        //отправитель.проголосовал = правда;
        sender.voted = true;
        //отправитель.делегат = кому;
        sender.delegate = to;
        //если (делегат_.проголосовал) 
        if (delegate_.voted) {
            // Если делегат уже проголосовал,напрямую добавляем к количеству голосов
            //предложения[делегат_ . голосование] .колво голосов += отправитель. масса;
            proposals[delegate_.vote].voteCount += sender.weight;
            //если
        } else {
            // Если делегат еще не проголосовал,добавить к ее весу.
            //делегат_.вес += отправитель.вес;
            delegate_.weight += sender.weight;
        }
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    // Отдайте свой голос (включая голоса, делегированные вам)в предложение `proposals[proposal].name`.
    //в функцию голосаование передаем uint предложение
    function vote(uint proposal) external {
        //Отправитель хранилища избирателей = избиратели[отправитель]
        Voter storage sender = voters[msg.sender];
        //требуют (отправитель вес не равен нулю «Не имеет права голоса»)
        require(sender.weight != 0, "Has no right to vote");
        //требуют отправитель проголосовал, "Уже проголосовал".
        require(!sender.voted, "Already voted.");
        //отправитель проголосовал
        sender.voted = true;
        //отправитель голосование = предложение
        sender.vote = proposal;
        // Если `proposal` выходит за пределы массива,это автоматически сгенерирует и вернет все изменения.
        //предложения [предложения]. колво голосов += отправитель. масса;
        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    // @dev Вычисляет победившее предложение с учетом всех предыдущих голосов.
    //в функцию выйграшное предложение которое возвращает его
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        //winningVoteCount победа подсчет голосов
        uint winningVoteCount = 0;
        //для p=0; p<длины предложения ;то следующий
        for (uint p = 0; p < proposals.length; p++) {
            //если предложение по индексу p подсчета голосов>победитель подсчета голосов
            if (proposals[p].voteCount > winningVoteCount) {
                //то победитель подсчета голосов = предложению поиндексу подсчета голосов
                winningVoteCount = proposals[p].voteCount;
                //победитель предложения = равно индесу
                winningProposal_ = p;
            }
        }
    }
// Вызывает функцию winingProposal() для получения индекса
// победителя, содержащегося в массиве предложений, а затем возвращает имя победителя
//winnerName имя победителя в формате 32байт
    function winnerName() external view
            returns (bytes32 winnerName_)
    {
        //имя победителя = предложения [выигрышное предложение] имя
        winnerName_ = proposals[winningProposal()].name;
    }
}