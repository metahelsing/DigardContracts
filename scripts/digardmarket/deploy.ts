import { ethers } from "hardhat";

async function main() {
  
  const DigardGameMarket = await ethers.getContractFactory("DigardGameMarket");
  const digardGameMarket = await DigardGameMarket.deploy();

  await digardGameMarket.deployed();

  console.log(`DigardGameMarket Contract Address: ${digardGameMarket.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});