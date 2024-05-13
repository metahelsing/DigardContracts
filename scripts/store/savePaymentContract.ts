import { ExtendContract } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const ELDAToken = new ExtendContract("ELDAToken");
  let eldaTokenAddress = await ELDAToken.getContractAddress();
  const DigardStore = new ExtendContract("DigardStore");
  const digardStore = await DigardStore.contractInstance(true);

  try {
    let result = await digardStore.savePaymentContract(eldaTokenAddress);
    result = await result.wait(1);

    if (result.status === 1) {
      console.log(
        `Elda Token: ${eldaTokenAddress} - savePaymentContract successfuly`
      );
    } else {
      console.log("savePaymentContract failed");
    }
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
