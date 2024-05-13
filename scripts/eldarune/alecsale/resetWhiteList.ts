import { ExtendContract } from "../../../utils/contractManager";

async function main() {
    
    const alecSale = new ExtendContract("AlecSale");
    const alecSaleInstance = await alecSale.contractInstance(true);
    await alecSaleInstance.resetWhiteList();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});