import whiteList from "./data/whiteList.json";
import { ExtendContract, contractAddress } from "../../../utils/contractManager";


async function main() {
    const eldaTokenContractAddress = await contractAddress("ELDAToken");
    const eldaruneSContractAddress = await contractAddress("EldaruneS");
    const alecSale = new ExtendContract("AlecSale");
    await alecSale.deployUpgradeable([eldaTokenContractAddress, eldaruneSContractAddress,whiteList, "750", "1", true]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});