import { contractAddress } from "../../../utils/contractManager";
import StakingRewardList from "./StakingRewardList.json";

export interface ClaimNftItem {
    nftContractIndex: number,
    tokenId: string,
    amount: number,
    deactive: boolean
}
export interface PlayerClaimItem {
    playerAddress:string,
    tokenAmount: number,
    lock: boolean,
    claimNftItems: Array<ClaimNftItem>
}
const fs = require("fs").promises;
async function main() {
    
    let playerClaimItems:Array<PlayerClaimItem> = [];
    const EldaTokenAddress = await contractAddress("ELDAToken");
    const EldaruneGameCollectionAddress = await  contractAddress("EldaruneGameCollection");
    for(let i = 0; i < StakingRewardList.length; i++) 
    {
       let playerClaimItem = playerClaimItems.find(f=> f.playerAddress === StakingRewardList[i].awardAddress);
       if(playerClaimItem) {
          let claimNftItem = playerClaimItem.claimNftItems.find(f=> f.tokenId === StakingRewardList[i].rewardId);
          if(claimNftItem) {
            claimNftItem.amount++;
          }
          else {
            claimNftItem = {amount: 1, deactive: false, nftContractIndex: 0, tokenId: StakingRewardList[i].rewardId};
            playerClaimItem.claimNftItems.push(claimNftItem);
          }
       }
       else {
         playerClaimItem = {lock: false, tokenAmount: 0, playerAddress: StakingRewardList[i].awardAddress, claimNftItems: [{amount: 1, deactive: false, nftContractIndex: 0, tokenId: StakingRewardList[i].rewardId}]};
         playerClaimItems.push(playerClaimItem);
       }
    }

    await fs.writeFile("./scripts/claim/data/results/result.json", JSON.stringify(playerClaimItems, null, 4));
    console.log(playerClaimItems.length);
    return playerClaimItems;
}
export const json = async ():Promise<any[]> => {
    return await main();
};
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});