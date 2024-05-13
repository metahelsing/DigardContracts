import { ExtendContract } from "../../../utils/contractManager";
import {EldaruneUtilityBoxFixture} from "./data/eldaruneUtilityBoxData";

async function main() {
    const {getMintProgram,tokenUri} = EldaruneUtilityBoxFixture([]);
    const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox");
    
    await eldaruneUtilityBox.deployUpgradeable([]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});