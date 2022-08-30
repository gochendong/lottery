# lottery solidity^0.8.16
## 区块链彩票模拟, 功能如下:
1. 具备管理员和参与者两种身份,管理员发起彩票活动,并设置彩票开奖时间,参与者在彩票发起至
彩票开奖间可参与购买彩票。
2. 每个参与者每次投资5WEI购买一注彩票,一个参与者可购买多注彩票。
3. 彩票中奖数字由4位0-9之间的数字构成,中奖数字随机生成,中奖者按购买对应数字的注数平分彩
票池,平台收取20%的手续费。
4. 管理员可多次发起彩票活动,但是同一时间仅支持一个彩票活动存在。
5. 需提供接口查询往期彩票的中奖数字和中奖者。

## 打开.env文件
分别填写
1. 自己的钱包私钥
2. https://dashboard.alchemy.com/ 上自己申请的APP私钥(NETWORK选择Rinkeby)

## 运行
npx hardhat run scripts/lottery-deploy.js --network rinkeby
完成部署

## 合约地址
Contract address: 0xBf0f4BDE301b932137D581CA31e8f9482A4d47D2
