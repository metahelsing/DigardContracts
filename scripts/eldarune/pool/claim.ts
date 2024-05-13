import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require("readline");

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
    const eldaPoolContractName = await question(
      "What is elda pool contract name?"
    );
    const claimAddress = await question("What is by claim address?");
    const eldaTokenAmount = await question("What is elda token amount?");
    let _eldaPoolContractName = String(eldaPoolContractName);
    let _claimAddress = String(claimAddress);
    let _eldaTokenAmount = ethers.utils.parseEther(String(eldaTokenAmount));
    const ELDAPool = new ExtendContract(_eldaPoolContractName);
    const eLDAPool = await ELDAPool.contractInstance(true);
    let result = await eLDAPool.claim(_claimAddress, _eldaTokenAmount);
    result = await result.wait(1);
    if (result.status === 1) {
      console.log("Token sended!");
    } else {
      console.log("Token failed!");
    }
    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
