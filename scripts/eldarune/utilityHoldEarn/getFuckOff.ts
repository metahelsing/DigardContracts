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
    const eldaruneHoldEarn = new ExtendContract("EldaruneHoldEarn");
    const eldaruneHoldEarnInstance = await eldaruneHoldEarn.contractInstance(
      true
    );
    let result = await eldaruneHoldEarnInstance.getFuckOff(
      "0xa16f7068BBB2952dECad0427DbA35Db47a918059",
      1
    );
    console.log(result);
    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
