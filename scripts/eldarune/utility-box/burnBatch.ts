import { ethers } from "hardhat";
import { ExtendContract, getProvider } from "../../../utils/contractManager";
import migrationList from "./data/migrationList.json";

async function main() {
  const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox");
  const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(
    true
  );
  const [owner] = await ethers.getSigners();
  let pageSize = 100;
  let pageLength = Math.ceil(migrationList.length / pageSize);
  for (let x = 35; x < pageLength; x++) {
    let startIndex = x * pageSize;
    let endIndex = startIndex + pageSize;
    if (endIndex > migrationList.length) {
      endIndex = migrationList.length;
    }
    let _migrationList = migrationList.slice(startIndex, endIndex);
    let tokenIds: any[] = [];
    for (var i = 0; i < _migrationList.length; i++) {
      tokenIds.push(_migrationList[i].tokenID);
    }

    const provider = getProvider();
    if (provider) {
      const balance = await provider.getBalance(owner.address);
      const balanceEther = ethers.utils.formatEther(balance);
      let result = await eldaruneUtilityBoxInstance.burnBatch(tokenIds, {
        gasLimit: 3000000,
      });
      result = await result.wait(1);
      if (result.status === 1) {
        console.log(
          `${x}/${pageLength} [${startIndex}-${endIndex}] - Success burned - Balance: ${balanceEther}`
        );
      } else {
        console.log("error");
      }
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
