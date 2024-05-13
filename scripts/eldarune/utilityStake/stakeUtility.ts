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
    const tokenId = await question("What is Token Id?");
    const amount = await question("What is Amount?");
    const stakingProgramId = await question("What is Staking Program Id?");
    const eldaruneUtilityCollectionStaking = new ExtendContract(
      "EldaruneUtilityCollectionStaking"
    );
    try {
      const eldaruneUtilityStakingInstance =
        await eldaruneUtilityCollectionStaking.contractInstance(true);
      let result = await eldaruneUtilityStakingInstance.stakeUtility(
        Number(tokenId),
        Number(amount),
        Number(stakingProgramId)
      );
      result = await result.wait(1);
      console.log(result);
      if (result.status === 1) {
        console.log(
          "Successfully  ----------------------------------------------------------->"
        );
      } else {
        console.log(
          "Error  ----------------------------------------------------------->"
        );
      }
    } catch (ex: any) {
      console.log("Error:", ex);
    }

    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
