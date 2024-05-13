import { ExtendContract } from "../../../utils/contractManager";

async function main() {
  const eldarunesTokenBoostCollection = new ExtendContract(
    "EldarunesTokenBoostCollection"
  );
  const eldarunesTokenBoostCollectionInstance =
    await eldarunesTokenBoostCollection.contractInstance(true);
  await eldarunesTokenBoostCollectionInstance.unpause();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
