import { ethers } from "hardhat";

import { ExtendContract } from "../../utils/contractManager";
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
    const minterContract = await question(
      "What is grant white list added address contract/me?"
    );
    const [owner, acc1, acc2] = await ethers.getSigners();
    const DigardNFTWhitelist = new ExtendContract("DigardNFTWhitelist");
    const digardNFTWhitelistInstance =
      await DigardNFTWhitelist.contractInstance(true, owner);

    //const DigardGameMarketAddress = ContractInfo.getContractAddress("DigardGameMarket");
    let contractAddress = "";

    if (String(minterContract) == "me") {
      contractAddress = owner.address;
    } else contractAddress = String(minterContract);

    try {
      const WHITELIST_ADDED_ROLE =
        await digardNFTWhitelistInstance.WHITELIST_ADDED_ROLE();
      console.log("WHITELIST_ADDED_ROLE:", WHITELIST_ADDED_ROLE);
      let result = await digardNFTWhitelistInstance.grantRole(
        WHITELIST_ADDED_ROLE,
        contractAddress
      );
      result = await result.wait(1);
      console.log(result);
      if (result.status === 1) {
        console.log("WHITELIST_ADDED_ROLE successfuly");
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
