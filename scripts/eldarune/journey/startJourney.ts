import { ethers, hardhatArguments } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";
import { ExtendedTask } from "./types/taskType";
const fs = require("fs").promises;
const readline = require("readline");

async function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  const question = (prompt: string) => {
    return new Promise((resolve, reject) => {
      rl.question(prompt, resolve);
    });
  };

  (async () => {
    const logger = new ethers.utils.Logger("debug");
    const _taskId = await question("What is taskId?");
    const EldaToken = new ExtendContract("ELDAToken");
    const EldaruneJourney = new ExtendContract("EldaruneJourney");
    const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
    const [owner] = await ethers.getSigners();
    const eldaTokenInstance = await EldaToken.contractInstance(true);
    const eldaruneJourneyInstance = await EldaruneJourney.contractInstance(
      true
    );
    const eldaruneGameCollectionAddress =
      await EldaruneGameCollection.getContractAddress();
    const eldaruneGameCollectionInstance =
      await EldaruneGameCollection.contractInstance(true);
    try {
      let taskId = Number(_taskId);
      let _networkName = hardhatArguments.network;
      let _taskList = await fs.readFile(
        `scripts/eldarune/journey/data/taskList-${_networkName}.json`,
        "utf8"
      );
      _taskList = JSON.parse(_taskList);
      let taskList: ExtendedTask[] = _taskList;
      let task = taskList.find((f) => f.task.taskId === Number(taskId));
      if (task) {
        const eldaruneJourneyAddress =
          await EldaruneJourney.getContractAddress();
        const ercTokenBalance = await eldaTokenInstance.balanceOf(
          owner.address
        );

        console.log(
          `Requirement Amount: ${
            task.requirementTokens.requirementToken.amount
          } - Balance: ${ethers.utils.formatEther(ercTokenBalance)}`
        );

        const approveTokenBalance = ethers.utils.parseUnits(
          task.requirementTokens.requirementToken.amount.toString(),
          "ether"
        );
        await eldaTokenInstance.approve(
          eldaruneJourneyAddress,
          approveTokenBalance
        );
        for (
          let i = 0;
          i < task.requirementNfts.requirementNfts[0].tokenIds.length;
          i++
        ) {
          const tokenBalance = await eldaruneGameCollectionInstance.balanceOf(
            owner.address,
            task.requirementNfts.requirementNfts[0].tokenIds[i]
          );
          console.log(
            `Token Id: ${task.requirementNfts.requirementNfts[0].tokenIds[i]} - Balance: ${tokenBalance}`
          );
        }

        await eldaruneGameCollectionInstance.setApprovalForAll(
          eldaruneJourneyAddress,
          true
        );
        const extStartRequirementNFTs = [
          {
            tokenAddress: eldaruneGameCollectionAddress,
            tokenId: "1000",
            amount: "1",
          },
          {
            tokenAddress: eldaruneGameCollectionAddress,
            tokenId: "1010",
            amount: "2",
          },
        ];
        console.log("taskId:", _taskId);
        console.log("extStartRequirementNFTs:", extStartRequirementNFTs);
        let result = await eldaruneJourneyInstance.startJourney(
          _taskId,
          extStartRequirementNFTs
        );

        result = await result.wait(1);

        if (result.status === 1) {
          console.log(
            `Start Task Successfull - Running Network ${hardhatArguments.network}`
          );
          console.log(
            `Requirement Amount: ${
              task.requirementTokens.requirementToken.amount
            } - Balance: ${ethers.utils.formatEther(ercTokenBalance)}`
          );
          for (
            let i = 0;
            i < task.requirementNfts.requirementNfts[0].tokenIds.length;
            i++
          ) {
            const tokenBalance = await eldaruneGameCollectionInstance.balanceOf(
              owner.address,
              task.requirementNfts.requirementNfts[0].tokenIds[i]
            );
            console.log(
              `Token Id: ${task.requirementNfts.requirementNfts[0].tokenIds[i]} - Balance: ${tokenBalance}`
            );
          }
          if (result.events.length > 0) {
            console.log(result.events);
            console.log(`SubscribeId: ${result.events[0].args["subscribeId"]}`);
            console.log(`Tx: ${result.code}`);
          }
        } else {
          console.log(
            `Start Task Failed - Running Network ${hardhatArguments.network}`
          );
        }
      }
    } catch (ex: any) {
      console.log(ex.message);

      // console.log(
      //   `Start Task Failed - Running Network ${hardhatArguments.network} Error:`,
      //   ex
      // );
    }
    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
