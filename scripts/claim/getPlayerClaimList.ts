import { ExtendContract } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const DigardClaim = new ExtendContract("DigardClaim");
  const digardClaim = await DigardClaim.contractInstance(true);

  try {
    const result = await digardClaim.getPlayerClaimList(
      "0xa16f7068BBB2952dECad0427DbA35Db47a918059"
    );

    let claimNftList = result.map(
      (
        rs: {
          nftContractIndex: number;
          tokenId: number;
          amount: number;
          deactive: boolean;
        },
        index: number
      ) => {
        return {
          nftContractIndex: rs.nftContractIndex,
          tokenId: rs.tokenId,
          amount: rs.amount,
          deactive: rs.deactive,
        };
      }
    );
    console.log(claimNftList);
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
