import {
  ExtendContract,
  contractAddress,
} from "../../../utils/contractManager";
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
    for (let i = 27; i < 29; i++) {
      let eldaTokenAddress = await contractAddress("ELDAToken");
      let _eldaPoolContractName = String("ELDAPool" + i);
      const ELDAPool = new ExtendContract(_eldaPoolContractName);
      const eLDAPool = await ELDAPool.deployUpgradeable([eldaTokenAddress]);
    }
    // const eldaPoolContractName = await question('What is elda pool contract name?');

    // rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
