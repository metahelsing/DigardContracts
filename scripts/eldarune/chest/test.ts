import StoreItems from "./data/saveChest.json";
import { ethers } from "hardhat";
import { ExtendContract, contractAddress } from "../../../utils/contractManager";
const readline = require('readline')

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        try {
            const [owner] = await ethers.getSigners();
            const mintTokenId = await question('What is Token Id?');
            const mintAmount = await question('What is Token Amount?');
            const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
            const EldaruneGameCollectionAddress = await EldaruneGameCollection.deployUpgradeable([]);
            const eldaruneGameCollection = await EldaruneGameCollection.contractInstance(true);
            await eldaruneGameCollection.mint(owner.address, Number(mintTokenId), Number(mintAmount), "0x");
           
            const EldaruneChest = new ExtendContract("EldaruneChest");
            const eldaruneChestAddress = await EldaruneChest.deployUpgradeable([EldaruneGameCollectionAddress]);
            const eldaruneChest = await EldaruneChest.contractInstance(true);
            await eldaruneChest.saveChest(StoreItems);
            await eldaruneGameCollection.setApprovalForAll(eldaruneChestAddress, true);
            const minter_role = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
            await eldaruneGameCollection.grantRole(minter_role, eldaruneChestAddress);
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