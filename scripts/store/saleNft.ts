
import { ExtendContract } from "../../utils/contractManager";
const readline = require('readline')


async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const _storeItemId = await question('What is store item id?');
        const _amount = await question('What is amount?');
        const DigardStore = new ExtendContract("DigardStore");
        const digardStore = await DigardStore.contractInstance(true);

        try {
            const storeItemId = Number(_storeItemId);
            const amount = Number(_amount);
            await digardStore.saleNft(storeItemId, amount);
            console.log("saleNft successfuly");

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


