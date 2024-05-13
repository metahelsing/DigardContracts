import { ExtendContract } from "../../../utils/contractManager";

async function main() {
    const alecSale = new ExtendContract("AlecSale");
    const alecSaleInstance = await alecSale.contractInstance(true);
    try {
        const result = await alecSaleInstance.mintAlec();
        console.log(result);
        console.log("Successfully  ----------------------------------------------------------->");
    } catch (ex: any) {
        console.log(ex);
    }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});