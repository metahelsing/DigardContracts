import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";

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
    const address = await question("What is Wallet Address?");

    const [
      owner,
      account1,
      account2,
      account3,
      account4,
      account5,
      account6,
      account7,
    ] = await ethers.getSigners();

    const DigardStore = new ExtendContract("DigardStore");
    const digardStore = await DigardStore.contractInstance(true);

    try {
      const PAUSER_ROLE = await digardStore.PAUSER_ROLE();
      const UPGRADER_ROLE = await digardStore.UPGRADER_ROLE();
      const ADMIN_ROLE = await digardStore.ADMIN_ROLE();
      const ITEM_SAVE_ROLE = await digardStore.ITEM_SAVE_ROLE();
      const hasPauserRoleResult = await digardStore.hasRole(
        PAUSER_ROLE,
        String(address)
      );
      const hasUpgraderRoleResult = await digardStore.hasRole(
        UPGRADER_ROLE,
        String(address)
      );
      const hasAdminRoleResult = await digardStore.hasRole(
        ADMIN_ROLE,
        String(address)
      );
      const hasItemSaveRoleResult = await digardStore.hasRole(
        ITEM_SAVE_ROLE,
        String(address)
      );
      console.log(`PauserRole: ${PAUSER_ROLE}`);
      console.log(`UpgraderRole: ${UPGRADER_ROLE}`);
      console.log(`AdminRole: ${ADMIN_ROLE}`);
      console.log(`ItemSaveRole: ${ITEM_SAVE_ROLE}`);
      console.log(
        `hasPauserRoleResult: ${hasPauserRoleResult}, hasUpgraderRoleResult: ${hasUpgraderRoleResult}, hasAdminRoleResult: ${hasAdminRoleResult}, hasItemSaveRoleResult: ${hasItemSaveRoleResult}`
      );
    } catch (ex) {
      console.log(ex);
    }
    rl.close();
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
