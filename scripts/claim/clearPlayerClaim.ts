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
    const playerAddress = await question("What is playerAddress?");
    const DigardClaim = new ExtendContract("DigardClaim");
    const digardClaim = await DigardClaim.contractInstance(true);

    try {
      let result = await digardClaim.clearPlayerClaim(
        String(playerAddress),
        true,
        true
      );
      result = await result.wait(1);
      if (result.status === 1) {
        console.log("clearPlayerClaim successfuly");
        process.exitCode = 1;
      } else console.log("clearPlayerClaim failed");
    } catch (ex) {
      console.log(ex);
    }
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
