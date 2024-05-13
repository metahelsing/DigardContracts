import { hardhatArguments } from "hardhat";
import { contractAddress } from "../../../utils/contractManager";

const fs = require("fs").promises;
async function main() {
    
    let items:any = [];
    let index = 1;
    let groupIndex = 1;
    let level = 1;
    let upgradePrice = 0;
    let upgradeChanceRatio = 100;
    let requiredTokenId = 10000;
    const EldaTokenAddress = await contractAddress("ELDAToken");
    const EldaruneGameCollectionAddress = await  contractAddress("EldaruneGameCollection");
    
    for(let i = 10000; i < 10090; i++) 
    {
        requiredTokenId = i;
        switch (i) {
            case 10000:
                break;
            case 10010:
            case 10020:
            case 10030:
            case 10040:
            case 10050:
            case 10060:
            case 10070:
            case 10080:
                if (i % 10 === 0) {
                    groupIndex++;
                    level = 1;
                   
                }
                break;
            default:
                requiredTokenId-=1;
            break;
            
        }
        switch (level) {
            case 1:
                upgradePrice = 0;
                upgradeChanceRatio = 100;
            break;
            case 2:
                upgradePrice = 20;
                upgradeChanceRatio = 100;
            break;
            case 3:
                upgradePrice = 30;
                upgradeChanceRatio = 90;
            break;
            case 4:
                upgradePrice = 50;
                upgradeChanceRatio = 80;
            break;
            case 5:
                upgradePrice = 75;
                upgradeChanceRatio = 75;
            break;
            case 6:
                upgradePrice = 100;
                upgradeChanceRatio = 70;
            break;
            case 7:
                upgradePrice = 200;
                upgradeChanceRatio = 60;
            break;
            case 8:
                upgradePrice = 300;
                upgradeChanceRatio = 50;
            break;
            case 9:
                upgradePrice = 400;
                upgradeChanceRatio = 40;
            break;
            case 10:
                upgradePrice = 500;
                upgradeChanceRatio = 20;
            break;
        }
        let item = {
            workshopGroupId: groupIndex,
            workshopItemId: index,
            tokenId: i,
            level: level,
            upgradePrice: upgradePrice,
            upgradeChanceRatio: upgradeChanceRatio,
            totalRequiredItem: 2,
            nftContract: EldaruneGameCollectionAddress,
            spendingContract: EldaTokenAddress,
            requiredItems: [{
                tokenId: requiredTokenId,
                nftContract: EldaruneGameCollectionAddress,
                amount: 2,
                failedBurningAmount: 1
            }]
        }
        items.push(item);
        level++;
        index++;
        
    }
    
    let _networkName = hardhatArguments.network;
    await fs.writeFile(`./scripts/workshop/data/results/upgradeSchema-${_networkName}.json`, JSON.stringify(items, null, 4));
    return items;
}
export const json = async ():Promise<any[]> => {
    return await main();
};
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});