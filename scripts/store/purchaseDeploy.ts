import { ExtendContract, contractAddress } from "../../utils/contractManager";

async function main() {
  const DigardStore = new ExtendContract("DigardStorePurchase");
  const digardStore = await DigardStore.deployUpgradeable([]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
