import { ethers } from "hardhat";
import { ExtendContract, contractAddress } from "../utils/contractManager";


async function main() {
    
    const eldaPoolManagerAddress = await contractAddress("EldaPoolManager");
    const digardClaimAddress = await contractAddress("DigardClaim");
    const EldaruneStakeGame = new ExtendContract("EldaruneStakeGame");
    
    await EldaruneStakeGame.deployUpgradeable([eldaPoolManagerAddress,digardClaimAddress]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});