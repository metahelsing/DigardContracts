import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";

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

    const EldaruneChest = new ExtendContract("EldaruneChest");
    const eldaruneChest = await EldaruneChest.contractInstance(true);

    try {
      const DEFAULT_ADMIN_ROLE = await eldaruneChest.DEFAULT_ADMIN_ROLE();
      const PAUSER_ROLE = await eldaruneChest.PAUSER_ROLE();
      const UPGRADER_ROLE = await eldaruneChest.UPGRADER_ROLE();

      const hasDefaultAdminRoleResult = await eldaruneChest.hasRole(
        DEFAULT_ADMIN_ROLE,
        String(address)
      );
      const hasPauserRoleResult = await eldaruneChest.hasRole(
        PAUSER_ROLE,
        String(address)
      );
      const hasUpgraderRoleResult = await eldaruneChest.hasRole(
        UPGRADER_ROLE,
        String(address)
      );
      console.log(`PauserRole: ${DEFAULT_ADMIN_ROLE}`);
      console.log(`PauserRole: ${PAUSER_ROLE}`);
      console.log(`UpgraderRole: ${UPGRADER_ROLE}`);

      console.log(
        `hasDefaultAdminRoleResult: ${hasDefaultAdminRoleResult}, hasPauserRoleResult: ${hasPauserRoleResult}, hasUpgraderRoleResult: ${hasUpgraderRoleResult}`
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
