import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";


async function main() {
    const [owner] = await ethers.getSigners();
    const eldaruneUtilityCollection = new ExtendContract("EldaruneUtilityCollection", true);
    const eldaruneUtilityCollectionAddress = await eldaruneUtilityCollection.getContractAddress();
    const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);
    const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(true);
    const minter_role = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";
    await eldaruneUtilityBoxInstance.grantRole(minter_role, eldaruneUtilityCollectionAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});