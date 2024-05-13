import { ExtendContract, contractAddress } from "../../utils/contractManager";
import items from "./data/results/result.json";
const readline = require('readline');

async function main() {

    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {

        const DigardWorkshop = new ExtendContract("DigardWorkshop");
        const DigardWorkshopInterface = await DigardWorkshop.contractInstance(true);


        try {
            const result = await DigardWorkshopInterface.getUpgradeLength(2);
            console.log(result);
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