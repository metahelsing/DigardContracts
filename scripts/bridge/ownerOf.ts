import { ethers } from "hardhat";
import {ExtendContract} from "../../utils/contractManager";
import {convertToWei} from "../../utils/helpers";
const readline = require('readline')

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
       const [owner, acc1] = await ethers.getSigners();
       const Elda721Contract  = new ExtendContract("BSCBridge", false);
       const elda721Contract = await Elda721Contract.contractInstance(true);
       const tokenId = await question('What is tokenId?');
        try {
            const balanceAddr = await elda721Contract?.ownerOf(Number(tokenId));
            console.log(balanceAddr == owner.address);
            console.log(balanceAddr);
            console.log(owner.address);
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