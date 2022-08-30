// SPDX-License-Identifier: UNLICENSED
pragma solidity^0.8.16;


contract Lottery {

    constructor() {
        owner = payable(msg.sender);
    }
    
    // 每次下注的数量
    uint lotteryBet = 5;

    // 发奖比例
    uint8 rewardRate = 80;

    // 中奖数字范围余数
    uint16 lotteryNum = 10000; // 0 ~ 9999

    //彩票期数
    uint public round;

	//管理员地址
    address payable owner;


    // 当期所有玩家
    address payable [] players;
  
    // 当期所有获奖者
    address  payable []  winners;

    // 彩票发起时间
    uint startTime;

    // 彩票开奖开始时间
    uint drawTime;

    // 当期购买记录（购买者的address, 彩票号码）
    mapping(address=>uint16[]) playerNums;

    // 当期获奖者的注数
    mapping(address=>uint) winnerBets;


    // 所有历史彩票信息
    lottery[] lotteryHistory;

    // 每期彩票信息
    struct lottery {
        uint round;
        uint16 luckyNum;
        address payable [] winners;
    }
  

    // 开启新一轮的彩票
    // time: 开奖时间
    function start(uint time) onlyOwner public {
        require(block.timestamp < time, "wrong start time");
        require(block.timestamp > drawTime, "one lottery is running"); // 同一时间只能有一个彩票活动
        round++;
        for (uint i = 0; i < players.length; i++) {
            delete playerNums[players[i]];
        }
        for (uint i = 0; i < winners.length; i++) {
            delete winnerBets[winners[i]];
        }
        delete players;
        delete winners;
        startTime = block.timestamp;
        drawTime = time;
    }

    function buy(uint16 num) public payable{
 		//保证彩民投注的金额为额定金额
        require(msg.value == lotteryBet);
        // num应是4位整数
        require(num < lotteryNum);
        // //只有在开奖时间之前才可以投注
        require(block.timestamp >= startTime && block.timestamp < drawTime);
        if (playerNums[msg.sender].length == 0) {
            players.push(payable(msg.sender));
        }
        playerNums[msg.sender].push(num);
    }

    function draw() onlyOwner payable public {
        // 确保在允许的开奖时间段内
        require(block.timestamp >= drawTime, "drawtime not arrived");
        // 确保已经有人下注, 同时避免重复开奖
        require(players.length > 0, "no players");

        uint randNum = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.timestamp)));
        uint16 luckyNum = uint16(randNum % lotteryNum);

        uint totalBets = 0;
        for (uint i = 0; i < players.length; i++) {
            address playerAddr = players[i];
            uint16[] storage nums = playerNums[playerAddr];
            for (uint j = 0; j< nums.length; j++) {
                if (nums[j] == luckyNum) {
                    winners.push(payable(playerAddr));
                    winnerBets[playerAddr]++;
                    totalBets++;
                }
            }

        }
        
        //根据当前盘内以太坊总额来确定本次中奖人可得到的奖金
        uint totalReward = address(this).balance*rewardRate / 100;
        //转账给中奖人
        for (uint i = 0; i < winners.length; i++) {
            address payable winner = winners[i];
            uint bets = winnerBets[winner];
            winner.transfer(totalReward * bets / totalBets);
        }
        //给管理员抽水
        if (address(this).balance > 0) {
            owner.transfer(address(this).balance);
        } 
        // 记录到历史
        lotteryHistory.push(lottery(round, luckyNum, winners));
   
    }

    function kill() onlyOwner public {
        selfdestruct(payable(msg.sender));
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        //代码修饰器所修饰函数的代码
        _;
    }

    //返回合约余额
	function getBalance() public view returns(uint){
        return address(this).balance;
    }
    // 返回owner余额
    function getBalanceOfOwner() public view onlyOwner returns(uint){
        return owner.balance;
    }
    //返回当期彩票的中奖地址(仅下期开始前有效, 否则可调用getLotteryHistory查询)
    function getWinners()public view returns(address payable [] memory){
        return winners;
    }
    //返回管理员的地址
    function getOwner()public view returns(address){
        return owner;
    }
    //返回当期所有玩家地址
    function getPlayers() public view returns(address payable [] memory) {
        return players;
    }
    // 获取往期彩票数据
    function getLotteryHistory() public view returns(lottery[] memory) {
        return lotteryHistory;
    }
    // 获取开奖时间
    function getDrawTime() public view returns(uint) {
        return drawTime;
    }
}