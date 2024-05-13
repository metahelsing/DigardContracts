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
    const claimAddress = await question("What is Digard Claim Address?");
    const eldaruneUtilityCollectionStaking = new ExtendContract(
      "EldaruneUtilityCollectionStaking"
    );
    const eldaruneUtilityStakingInstance =
      await eldaruneUtilityCollectionStaking.contractInstance(true);
    let result = await eldaruneUtilityStakingInstance.setClaimAddress(
      String(claimAddress)
    );
    result = await result.wait(1);
    if (result.status === 1) {
      console.log("Success");
    } else {
      console.log("Error");
    }

    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
