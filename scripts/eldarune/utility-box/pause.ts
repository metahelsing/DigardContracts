import { ExtendContract } from "../../../utils/contractManager";

async function main() {
  const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox");
  const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(
    true
  );
  await eldaruneUtilityBoxInstance.unpause();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
