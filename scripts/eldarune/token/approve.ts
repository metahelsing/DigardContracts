import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

let contractAbi: any;
const readline = require('readline')

async function main() 
{

    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const approveContractName = await question('What is approve contract?');
        const approveAmount = await question('What is approve amount?')
        const EldaToken = new ExtendContract("ELDAToken");
        const EldaTokenInterface = await EldaToken.contractInstance(true);
        const exContract = new ExtendContract(String(approveContractName));
        const approveContractAddress = await exContract.getContractAddress();
        try {
            const amount = ethers.utils.parseEther(String(approveAmount));
            await EldaTokenInterface.approve(approveContractAddress, amount);
            console.log("approve successfuly");
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