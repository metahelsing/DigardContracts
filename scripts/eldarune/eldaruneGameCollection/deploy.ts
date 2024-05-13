import { ExtendContract } from "../../../utils/contractManager";

async function main() {
  
  const EldaruneGameCollection = new ExtendContract("EldaruneGameCollection");
  const result = await EldaruneGameCollection.getImplementationAddress();
  const eldaruneGameCollection = await EldaruneGameCollection.deployUpgradeable([]);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});