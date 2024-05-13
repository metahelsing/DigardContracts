import { ExtendContract, contractAddress } from "../../utils/contractManager";
const readline = require('readline');

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const _question1 = await question('./scripts/eldarune/eldaruneGameCollection/setApprovalForAll.ts - Did you run?');
        if (String(_question1) == "Y") {
            const _question2 = await question('./scripts/eldarune/token/approve.ts - Did you run?');
            if (String(_question2) == "Y") {
                const _workshopItemId = await question('The workshopItemId you want to upgrade?');
                const DigardWorkshop = new ExtendContract("DigardWorkshop");
                const DigardWorkshopInterface = await DigardWorkshop.contractInstance(true);

                try {
                    const workshopItemId = Number(_workshopItemId);
                    const result = await DigardWorkshopInterface.UpgradeItem(workshopItemId);
                    console.log(result);


                } catch (ex) {
                    console.log(ex);
                }
                rl.close()
            }
        }

    })()
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});