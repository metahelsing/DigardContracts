
import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')


async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

  (async () => {
    const _tokenId = await question('What is tokenId?');
    const EldaruneChest = new ExtendContract("EldaruneChest");
    const [owner, account1, account2, account3, account4, account5, account6, account7] = await ethers.getSigners();
    const eldaruneChest = await EldaruneChest.contractInstance(true);
    const provider = ethers.provider;
    try {
      let estGasLimit = await eldaruneChest.getEstimatedGasLimit("openPackage", [String(_tokenId)], "0xa16f7068BBB2952dECad0427DbA35Db47a918059");
      const gasPrice = await provider.getGasPrice();
      const functionName = 'openPackage'; // Çağırmak istediğiniz fonksiyon adı
      const tokenId = String(_tokenId); // Fonksiyona vermek istediğiniz parametre

      // Fonksiyonu çağırma işlemi
      let tx = await eldaruneChest.functions[functionName](tokenId, {
        gasLimit: estGasLimit,
        gasPrice: gasPrice
      });

      tx = await tx.wait();
      if (tx.status === 1) {
        console.log("openPackage successfuly");
        // console.log(tx);
      }
      else console.log("openPackage error");


    } catch (ex) {
      console.log(ex);
    }
    rl.close()
  })()
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


