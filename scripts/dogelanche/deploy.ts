import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
async function main() {
  const [owner] = await ethers.getSigners();
  const Dogelanche = new ExtendContract("Dogelanche");
  const dogelancheAddress = await Dogelanche.deploy([], owner);
  console.log(`Dogelanche Contract Address: ${dogelancheAddress}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
