import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";


async function main() {
    const [owner] = await ethers.getSigners();
    const eldaruneUtilityCollection = new ExtendContract("EldaruneUtilityCollection", true);
    const eldaruneUtilityCollectionAddress = await eldaruneUtilityCollection.getContractAddress();
    const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);
    const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(true);
    const burn_role = "0xe97b137254058bd94f28d2f3eb79e2d34074ffb488d042e3bc958e0a57d2fa22";
   
    await eldaruneUtilityBoxInstance.grantRole(burn_role, eldaruneUtilityCollectionAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});