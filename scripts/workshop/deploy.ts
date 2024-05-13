import { ExtendContract } from "../../utils/contractManager";

async function main() {
  const DigardWorkshop = new ExtendContract("DigardWorkshop");
  try {
    let tx = await DigardWorkshop.deployUpgradeable([
      "0xa16f7068BBB2952dECad0427DbA35Db47a918059",
    ]);
    console.log("success");
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
