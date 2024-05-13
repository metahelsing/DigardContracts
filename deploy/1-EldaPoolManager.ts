import { ExtendContract, contractAddress } from "../utils/contractManager";

const readline = require('readline')

async function main() {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

  (async () => {
    
    const PoolManager = new ExtendContract("EldaPoolManager");
    const eldaTokenContractAddress = await contractAddress("ELDAToken");
    const poolManager = await PoolManager.deployUpgradeable([eldaTokenContractAddress, []]);
      
    rl.close()
  })()
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});