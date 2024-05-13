import { ethers } from "hardhat";
import {ContractInfo} from "../constants";

async function main(){
    let arr: { id: any; nftContract: any; tokenId: any; seller: any; buyer: any; price: any; remaingAmount: any; isRemaing: boolean; tokenStandart: string; spendingContract: any; state: number; }[] = [];
    const DigardGameMarketAddress = await ContractInfo.getContractAddress("DigardGameMarket");
    const DigardGameMarketAbi = await (await ethers.getContractFactory("DigardGameMarket")).interface;
    const [owner] = await ethers.getSigners();
    const DigardGameMarketInstance = await new ethers.Contract(DigardGameMarketAddress, DigardGameMarketAbi, owner);
    
    try {
       const results = await DigardGameMarketInstance.fetchActiveItems();
       
       results.forEach((element: {
           spendingContract: any;
           remaingAmount: any;
           price: any;
           buyer: any;
           seller: any;
           tokenId: any;
           nftContract: any; id: any; 
            }) => {
          arr.push({
            id: element.id,
            nftContract: element.nftContract,
            tokenId: element.tokenId,
            seller: element.seller,
            buyer: element.buyer,
            price: element.price,
            remaingAmount: element.remaingAmount,
            isRemaing: false,
            tokenStandart: 'ERC1155',
            spendingContract: element.spendingContract,
            state: 0
          });
       });
       console.log(arr);
    } catch (ex) {
        console.log(ex);
    }
}
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });