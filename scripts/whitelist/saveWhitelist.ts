import { ethers, hardhatArguments } from "hardhat";
import { ExtendContract, contractAddress } from "../../utils/contractManager";
import { newLineToArray } from "../../utils/helpers";
import whiteList from "./data/whitelist";
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
    const DigardNFTWhitelist = new ExtendContract("DigardNFTWhitelist");
    const DigardNFTWhitelistInterface =
      await DigardNFTWhitelist.contractInstance(true);
    try {
      let _networkName = hardhatArguments.network;
      let whitelistJSON = await fs.readFile(
        `scripts/whitelist/data/whitelist-${_networkName}.json`,
        "utf8"
      );
      whitelistJSON = JSON.parse(whitelistJSON);
      let arr = newLineToArray(whiteList);
      whitelistJSON.whiteListAddresses = arr.slice(800, 906);

      arr.forEach((addr) => {
        try {
          ethers.utils.getAddress(addr);
        } catch (error) {
          console.log("Geçersiz: ", addr);
        }
      });

      whitelistJSON.whiteListAddresses = [
        "0xE8d2d8DA13cD8269B15831AAD39A72C6e4Dbf3f8",
        "0x265f1EfcB1328d02d09eD523497B56379fFC11ca",
        "0xAF561f0339F526FffD4Fc6216ca5c19Acdf6E5Df",
      ];
      let result = await DigardNFTWhitelistInterface.saveWhitelist(
        whitelistJSON,
        {
          gasLimit: 4000000,
        }
      );

      result = await result.wait(1);
      if (result.status === 1) {
        console.log(
          `DigardNFTWhitelist saveWhitelist Successfull - Running Network ${hardhatArguments.network}`
        );
      } else {
        console.log(
          `DigardNFTWhitelist saveWhitelist UnSuccessfull - Running Network ${hardhatArguments.network}`
        );
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
