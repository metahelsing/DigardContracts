import MigrationList from "./migrationList.json";
const readline = require("readline");
export interface MigrationGroup {
  owner: string;
  tokenIds: Array<number>;
  amounts: Array<number>;
}
export interface MigrationItem {
  tokenID: string;
  amount: number;
}

const fs = require("fs").promises;
async function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  (async () => {
    let migrationGroup: Array<MigrationGroup> = [];

    for (let i = 0; i < MigrationList.length; i++) {
      let tokenIdIndex = -1;
      switch (String(MigrationList[i].rarity)) {
        case "common":
          tokenIdIndex = 0;
          break;
        case "uncommon":
          tokenIdIndex = 1;
          break;
        case "rare":
          tokenIdIndex = 2;
          break;
        case "epic":
          tokenIdIndex = 3;
          break;
        case "legendary":
          tokenIdIndex = 4;
          break;
        case "ancient":
          tokenIdIndex = 5;
          break;
        case "unique":
          tokenIdIndex = 6;
          break;
      }
      if (tokenIdIndex > -1) {
        let fIndex = migrationGroup.findIndex(
          (f) => f.owner === MigrationList[i].owner
        );
        if (fIndex > -1) {
          migrationGroup[fIndex].amounts[tokenIdIndex] += 1;
        } else {
          let migrationItem = {
            owner: MigrationList[i].owner,
            tokenIds: [1, 2, 3, 4, 5, 6, 7],
            amounts: [0, 0, 0, 0, 0, 0, 0],
          };
          migrationItem.amounts[tokenIdIndex] += 1;
          migrationGroup.push(migrationItem);
        }
      }
    }

    await fs.writeFile(
      `./scripts/eldarune/utilityCollection/data/results/lastMigrationList.json`,
      JSON.stringify(migrationGroup, null, 4)
    );

    return migrationGroup;
  })();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
