import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

const readline = require('readline')

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const address = await question('What is balance of Wallet Address?')
        const tokenId = await question('What is balance of Token Id?')
        
        const [owner, account1, account2, account3, account4, account5, account6, account7] = await ethers.getSigners();
        
        const EldaruneGameCollection = new ExtendContract("EldaruneUtilityCollection");
        const eldaruneGameCollection = await EldaruneGameCollection.contractInstance(true);

        try {
            const newNftBalance = await eldaruneGameCollection.balanceOf(address, tokenId);
            console.log(Number(newNftBalance));

        } catch (ex) {
            console.log(ex);
        } rl.close()
    })()
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});