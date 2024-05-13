import { ethers } from "hardhat";
import { ExtendContract, getProvider } from "../../../utils/contractManager";
const readline = require('readline')
async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

  (async () => {
    const invalidNonce = await question('What is nonce?');
    const provider = getProvider();
    if(provider) {
        const [owner] = await ethers.getSigners();
        
        //const tx = await provider.getTransaction(String(invalidTxHash));
        // const txNonce = tx.nonce;
        // const gasPrice = tx.gasPrice;
        const nonce = Number(invalidNonce);
        const tx = {
            nonce: nonce,
            to: ethers.constants.AddressZero,
            data: '0x',
            gasPrice: ethers.utils.parseUnits("80", "gwei"),
            chainId: 1
          }; 

        const cancelTxResponse = await owner.sendTransaction(tx);
        console.log('Geçersiz kılma işlemi hash:', cancelTxResponse.hash);
    }
    
    rl.close()
  })()
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
