import { ethers } from "hardhat";
import { ExtendContract,contractAddress } from "../../../utils/contractManager";

const readline = require('readline')

async function main() 
{

    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const approveContractName = await question('What is setApprovalForAll contract?');
        
        
        const [owner] = await ethers.getSigners();
        const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
        const eldaruneGameCollection = await EldaruneGameCollection.contractInstance(true);
        
        const approveContractAddress = await contractAddress(String(approveContractName));
        try {
            await eldaruneGameCollection.setApprovalForAll(approveContractAddress, true);
            console.log("setApprovalForAll successfuly");
        } catch (ex){
            console.log(ex);
        }

        rl.close()
    })()

}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});