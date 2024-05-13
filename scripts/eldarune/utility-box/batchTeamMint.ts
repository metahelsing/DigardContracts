import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline');

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const mintWallet = await question('What is mint wallet?');
        const [owner] = await ethers.getSigners();
        const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);

        const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(true);

        await eldaruneUtilityBoxInstance.batchTeamMint(String(mintWallet));
        rl.close()
    })()
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});