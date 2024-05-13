
import { ExtendContract } from "../../utils/contractManager";
const readline = require('readline')


async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const toAddress = await question('What is to address?');
        const ELDAToken = new ExtendContract("ELDAToken");
        let eldaTokenAddress = await ELDAToken.getContractAddress();
        const DigardStore = new ExtendContract("DigardStore");
        const digardStore = await DigardStore.contractInstance(true);

        try {
            const to = String(toAddress);
            await digardStore.saveSaleOwner(to);
            console.log("saveSaleOwner successfuly");

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


