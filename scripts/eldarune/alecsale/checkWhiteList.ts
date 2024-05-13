import { ExtendContract } from "../../../utils/contractManager";


async function main() {
    
    const alecSale = new ExtendContract("AlecSale");
    const alecSaleInstance = await alecSale.contractInstance(true);
    
    const result = await alecSaleInstance.checkWhiteList("0xaaf7595e927e2af70f6f9f90ef9424bef9c4678c");
    console.log(result);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});