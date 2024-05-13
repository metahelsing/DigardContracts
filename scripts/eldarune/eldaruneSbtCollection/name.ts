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
    const EldaruneSbtCollection = new ExtendContract("EldaruneS");
    const eldaruneSbtCollection = await EldaruneSbtCollection.contractInstance(
      true
    );

    try {
      const name = await eldaruneSbtCollection.name();
      console.log("Collection name: ", name);
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
