import whiteList from "./data/whiteList19";
import { ExtendContract } from "../../../utils/contractManager";
import { newLineToArray } from "../../../utils/helpers";


async function main() {
    
    const alecSale = new ExtendContract("AlecSale");
    const alecSaleInstance = await alecSale.contractInstance(true);
    
    
    let arr = newLineToArray(whiteList);
    let start = 0;
    let end = arr.length-1;
    let length = arr.length;
    arr = arr.slice(start,end);
   
    try {
      await alecSaleInstance.saveWhiteList(["0x17C3962c6608ba193b308CC6de741018F33b13D5","0xD48D2AC2123AbE6D38359B17d28908f6e3A3cB89", "0xa4b0a22582e58be27fa6a251c44da911d855d1ce"]);
      console.log(`start: ${start} - end: ${end} - count: ${length}`);
    } catch (ex) {
      console.log("Error:", ex);
    }
    
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});