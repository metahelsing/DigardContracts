import { hardhatArguments } from "hardhat";
import miragePackList from "./data/miragePackList";
import mintedList from "./data/mirage/mintedList.json";
import whiteList from "./data/mirage/whiteList.json";
import { ExtendContract } from "../../../utils/contractManager";
import { newLineToArray } from "../../../utils/helpers";
const readline = require("readline");
const fs = require("fs").promises;

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
    const DigardStore = new ExtendContract("DigardStore");
    const digardStore = await DigardStore.contractInstance(true);

    try {
      // let mintedList: any = [];
      // let arrayList: any = [];
      // let airdropList: any = [];
      let arr = newLineToArray(miragePackList);
      const filter = digardStore.filters["SaleStoreItem"](); // Olay filtresi oluşturun
      const fromBlock = 35273733;
      const toBlock = 35279260;
      // let _airDropList: any = [];
      // for (let i = 0; i < whiteList.length; i++) {
      //   let index = mintedList.findIndex((f: string) => f === whiteList[i]);
      //   if (index === -1) {
      //     if (
      //       _airDropList.findIndex((f: string) => f === whiteList[i]) === -1
      //     ) {
      //       _airDropList.push(whiteList[i]);
      //     }
      //   }
      //   fs.writeFile(
      //     `./scripts/eldarune/eldaruneGameCollection/data/mirage/airDropList.json`,
      //     JSON.stringify(_airDropList, null, 4)
      //   );
      // }
      digardStore
        .queryFilter(filter, fromBlock, toBlock)
        .then((events: any) => {
          for (let i = 0; i < events.length; i++) {
            let storeItemId = Number(events[i].args["storeItemId"]);
            let buyerAddress = events[i].args["buyerAddress"];
            if (storeItemId === 14) {
              // let index = arrayList.findIndex(
              //   (f: any) => f.walletAddress === buyerAddress
              // );
              // if (index > -1) {
              //   arrayList[index].minted += 1;
              // } else {
              //   arrayList.push({ walletAddress: buyerAddress, minted: 1 });
              // }
              let mintedListIndex = mintedList.findIndex(
                (f: any) => f === buyerAddress
              );
              if (mintedListIndex === -1) {
                if (mintedList.findIndex((f) => f === buyerAddress) === -1) {
                  mintedList.push(buyerAddress);
                }
              }
              fs.writeFile(
                `./scripts/eldarune/eldaruneGameCollection/data/mirage/mintedList.json`,
                JSON.stringify(mintedList, null, 4)
              );
            }
            console.log(`${i}/${events.length}`);
          }
        })
        .catch((error) => {
          console.error("Hata:", error);
        });

      // fs.writeFile(
      //   `./scripts/eldarune/eldaruneGameCollection/data/mirage/whiteList.json`,
      //   JSON.stringify(arr, null, 4)
      // );

      // for (let i = 0; i < arr.length; i++) {
      //   let balance = await eldaruneGameCollection.balanceOf(arr[i], "8");
      //   balance = Number(balance);

      //   await fs.writeFile(
      //     `./scripts/eldarune/eldaruneGameCollection/data/miragePackBalance.json`,
      //     JSON.stringify({ address: arr[i], balance: Number(balance) }, null, 4)
      //   );
      //   if (balance === 0) {
      //     await fs.writeFile(
      //       `./scripts/eldarune/eldaruneGameCollection/data/miragePackZeroBalance.json`,
      //       JSON.stringify(
      //         { address: arr[i], balance: Number(balance) },
      //         null,
      //         4
      //       )
      //     );
      //   }
      //   console.log("i:", i);
      // }
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
