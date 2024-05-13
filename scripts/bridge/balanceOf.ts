import { ethers } from "hardhat";
import {ExtendContract} from "../../utils/contractManager";
import {convertToWei} from "../../utils/helpers";
const readline = require('readline')

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
       const [owner, acc1] = await ethers.getSigners();
       const BSCBridgeContract  = new ExtendContract("BSCBridge", false);
       const bSCBridgeContract = await BSCBridgeContract.contractInstance(true);
       
        try {
            const balanceAddr = await bSCBridgeContract?.balanceOf(owner.address);
            
            console.log(balanceAddr);
           
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