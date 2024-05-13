import { ExtendContract } from "../../../utils/contractManager";

async function main() {
  const EldaruneRedBoxCollection = new ExtendContract(
    "EldaruneRedBoxCollection"
  );
  const result = await EldaruneRedBoxCollection.getImplementationAddress();
  const eldaruneRedBoxCollection =
    await EldaruneRedBoxCollection.deployUpgradeable([]);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
