import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import {EldaruneUtilityBoxFixture} from "./data/eldaruneUtilityBoxData";

async function main() {
    const [owner] = await ethers.getSigners();
    const {getMintProgram} = EldaruneUtilityBoxFixture([]);
    const eldaruneUtilityCollection = new ExtendContract("EldaruneUtilityBox", true);
    const eldaruneUtilityCollectionInstance = await eldaruneUtilityCollection.contractInstance(true);
    const mintProgram = await getMintProgram();
    await eldaruneUtilityCollectionInstance.updateMintProgram(mintProgram);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});