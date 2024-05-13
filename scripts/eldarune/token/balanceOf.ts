import { ethers } from "hardhat";
import { ContractInfo } from "../constants";
const readline = require('readline')

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const _address = await question('What is to address?');
        const [owner] = await ethers.getSigners();
        const EldaTokenAddress = await ContractInfo.getContractAddress("EldaToken");
        const EldaTokenAbi = await (await ethers.getContractFactory("EldaToken")).interface;
        const EldaTokenInterface = await new ethers.Contract(EldaTokenAddress, EldaTokenAbi, owner);
        let oAddress = owner.address;
        if(_address != "me"){
            oAddress = String(_address);
        }
        try {
            const tokenBalance = await EldaTokenInterface.balanceOf(oAddress);
            const tokenBalanceStr = ethers.utils.formatUnits(tokenBalance, "ether");
            console.log(tokenBalanceStr);

        } catch (ex) {
            console.log(ex);
        } rl.close()
    })()
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});