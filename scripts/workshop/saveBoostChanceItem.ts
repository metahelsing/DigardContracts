import { ethers, hardhatArguments } from "hardhat";
import {
  ExtendContract,
  contractAddress,
  getProvider,
} from "../../utils/contractManager";
const readline = require("readline");
const fs = require("fs").promises;

async function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const question = (prompt: string) => {
    return new Promise((resolve, reject) => {
      rl.question(prompt, resolve);
    });
  };

  (async () => {
    const [owner] = await ethers.getSigners();
    const provider = getProvider();
    const DigardWorkshop = new ExtendContract("DigardWorkshop");
    const DigardWorkshopInterface = await DigardWorkshop.contractInstance(true);
    try {
      if (provider) {
        const balance = await provider.getBalance(owner.address);
        let _networkName = hardhatArguments.network;
        let boostChanceList = await fs.readFile(
          `scripts/workshop/data/boostChanceList-${_networkName}.json`,
          "utf8"
        );
        boostChanceList = JSON.parse(boostChanceList);
        const balanceEther = ethers.utils.formatEther(balance);

        console.log("owner:", owner.address, "-balance:", balanceEther);
        let result = await DigardWorkshopInterface.saveBoostChanceItem(
          boostChanceList.workshopGroupIds,
          boostChanceList.boostChanceItems,
          { gasLimit: 10000000 }
        );
        result = await result.wait(1);
        if (result.status === 1) {
          console.log("Success");
        } else {
          console.log("Error");
        }
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
