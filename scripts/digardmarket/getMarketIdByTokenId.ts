import { ethers } from "hardhat";
import { ContractInfo } from "../constants";
const readline = require('readline')

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const tokenId = await question('Start TokenId?')
        const DigardGameMarketAddress = await ContractInfo.getContractAddress("DigardGameMarket");
        const DigardGameMarketAbi = await (await ethers.getContractFactory("DigardGameMarket")).interface;
        const [owner] = await ethers.getSigners();
        const DigardGameMarketInstance = await new ethers.Contract(DigardGameMarketAddress, DigardGameMarketAbi, owner);

        try {
            const marketId = await DigardGameMarketInstance.getMarketIdByTokenId(Number(tokenId));
            console.log("TokenId: " + Number(tokenId) + " MarketId: " + Number(marketId));
            
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