import PlayerClaimItem from "./data/PlayerClaimItem.json";
import { ethers } from "hardhat";
import { ExtendContract, contractAddress } from "../../utils/contractManager";
const readline = require('readline')

async function main() {
    const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

    const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

    (async () => {
        try {
            const [owner] = await ethers.getSigners();
            const playerAddress = await question('What is playerAddress?');
            
            const ELDAToken = new ExtendContract("ELDAToken");
            const eldaTokenAddress = await ELDAToken.deploy();
            const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
            const eldaruneGameCollectionAddress = await EldaruneGameCollection.deployUpgradeable([]);
            
            PlayerClaimItem[0].playerAddress = String(playerAddress);
            const DigardClaim = new ExtendContract("DigardClaim");
            await DigardClaim.deployUpgradeable([eldaTokenAddress, [eldaruneGameCollectionAddress]]);
            const digardClaim = await DigardClaim.contractInstance(true);
            await digardClaim.addPlayerClaimBatch(PlayerClaimItem);

           
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