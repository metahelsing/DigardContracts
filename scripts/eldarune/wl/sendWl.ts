import whiteList from "./data/whiteList2.json";
import whiteList3 from "./data/whiteList3";
import { ExtendContract } from "../../../utils/contractManager";
import { newLineToArray } from "../../../utils/helpers";


async function main() {
    
    const alecSale = new ExtendContract("AlecSale");
    const alecSaleInstance = await alecSale.contractInstance(true);
    const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
    const eldaruneGameCollection = await EldaruneGameCollection.contractInstance(true);
    let arr = whiteList;
    arr = newLineToArray(whiteList3);
    arr = ["0xa32CA6fE4530F00e7E9fCf4e00874d888741626c"];
    await alecSaleInstance.saveWhiteList(arr);
    const tokenIds = [1,2,3,4];
    const amounts =  [1,1,1,1];
    await eldaruneGameCollection.mintAddressBatch(arr, tokenIds, amounts, "0x");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});