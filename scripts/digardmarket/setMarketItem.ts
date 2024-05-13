import { ethers } from "hardhat";
import { ContractInfo } from "../constants";
const readline = require('readline')

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        const marketId = await question('Start MarketId?');
        const _price = await question('New Price?')
        const DigardGameMarketAddress = await ContractInfo.getContractAddress("DigardGameMarket");
        const DigardGameMarketAbi = await (await ethers.getContractFactory("DigardGameMarket")).interface;
        const [owner] = await ethers.getSigners();
        const DigardGameMarketInstance = await new ethers.Contract(DigardGameMarketAddress, DigardGameMarketAbi, owner);

        try {
            const price = ethers.utils.parseEther(String(_price));
            await DigardGameMarketInstance.setMarketItem(Number(marketId), price, 0);
            console.log("MarketId: " + Number(marketId) + " Price: " + _price);
            
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