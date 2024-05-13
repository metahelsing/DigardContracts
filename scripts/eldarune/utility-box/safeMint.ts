import { ethers } from "hardhat";
import { ExtendContract } from "../../../utils/contractManager";


async function main() {

  const eldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox");
  const eldaruneUtilityBoxInstance = await eldaruneUtilityBox.contractInstance(true);

  //256 - 1
  //257 - 1
  //258 - 1
  //259 - 1
  //260 - 1

  //261 - 2
  //262 - 2
  //263 - 2
  //264 - 2
  //265 - 2

  //266 - 3
  //267 - 3
  //268 - 3
  //269 - 3

  //await eldaruneUtilityBoxInstance.safeMint("0xa16f7068BBB2952dECad0427DbA35Db47a918059", "common/red.json");
  //await eldaruneUtilityBoxInstance.safeMint("0xa16f7068BBB2952dECad0427DbA35Db47a918059", "common/blue.json");
  //await eldaruneUtilityBoxInstance.safeMint("0x0A1489c701dd4bDA36F12c558C737218319a8ae4", "common/blue.json");
  let result = await eldaruneUtilityBoxInstance.safeMint("0xAF1731fA16f6eA8f5f291c0E053243BEb2f2A59d", "rare/blue.json");
  //result = await eldaruneUtilityBoxInstance.safeMint("0xAF1731fA16f6eA8f5f291c0E053243BEb2f2A59d", "rare/green.json");
  result = await result.wait();
  console.log(result);
  let eventFilter = eldaruneUtilityBoxInstance.filters.Transfer();
  if (eventFilter) {
    let events = await eldaruneUtilityBoxInstance.queryFilter(eventFilter, result.blockNumber - 10, 'latest');
    console.log(events);
    if (events) {
      console.log("tokenId:" + Number(events[0].args?.tokenId));
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});