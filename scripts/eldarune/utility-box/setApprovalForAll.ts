import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
const readline = require('readline');

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const spenderWallet = await question('What is spender account?');
        const [owner, account1, account2, account3, account4, account5, account6] = await ethers.getSigners();
        const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);

        const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(true, account6);

        await eldaruneUtilityBoxInstance.setApprovalForAll(String(spenderWallet), true);
        rl.close()
    })()
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});