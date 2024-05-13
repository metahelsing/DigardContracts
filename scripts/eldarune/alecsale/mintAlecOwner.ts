import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline')
async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const toAddress = await question('What is to address?');
        const alecSale = new ExtendContract("AlecSale");
        const alecSaleInstance = await alecSale.contractInstance(true);
        try {
            const result = await alecSaleInstance.mintAlecOwner(String(toAddress));
            console.log(result);
            console.log("Successfully  ----------------------------------------------------------->");
        } catch (ex: any) {
            console.log(ex);
        }
        rl.close()
    })()
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});