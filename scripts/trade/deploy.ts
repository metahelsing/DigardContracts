import { ethers } from "hardhat";
import { ExtendContract, contractAddress } from "../../utils/contractManager";

async function main() {
  const [owner, acc1] = await ethers.getSigners();
  let eldaTokenAddress = await contractAddress("ELDAToken");

  const EldaTrader = new ExtendContract("EldaTrader");
  const eldaTrader = await EldaTrader.deployUpgradeable(
    [
      "0x3cB315B7943D95b67c407465b59aA66aB1B5e22f",
      "0x3cB315B7943D95b67c407465b59aA66aB1B5e22f",
      "0x3cB315B7943D95b67c407465b59aA66aB1B5e22f",
      "0x10ed43c718714eb63d5aa57b78b54704e256024e",
    ],
    acc1
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
