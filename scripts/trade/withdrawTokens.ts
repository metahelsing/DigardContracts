import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  (async () => {
    const [owner, acc1] = await ethers.getSigners();
    const ELDAToken = new ExtendContract("ELDAToken");
    let eldaTokenAddress = await ELDAToken.getContractAddress();

    const EldaTrader = new ExtendContract("EldaTrader");
    let eldaTraderAddress = await EldaTrader.getContractAddress();
    const eldaTrader = await EldaTrader.contractInstance(true, acc1);
    const eldaToken = await ELDAToken.contractInstance(true, acc1);
    try {
      let _eldaTokenAmount = ethers.utils.parseEther("400000");
      const traderBalance = await eldaToken.balanceOf(eldaTraderAddress);
      let result = await eldaTrader.withdrawTokens(
        eldaTokenAddress,
        _eldaTokenAmount
      );
      result = await result.wait(1);

      if (result.status === 1) {
        console.log("İşlem başarılı");
      } else {
        console.log(result);
        console.log("İşlem başarısız");
      }
    } catch (ex) {
      console.log(ex);
    }

    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
