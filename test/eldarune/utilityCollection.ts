import { ethers } from "hardhat";
import { expect, use } from "chai";
import { solidity } from "ethereum-waffle";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import { EldaruneUtilityBoxFixture } from "./data/eldaruneUtilityBoxData";
import { EldaruneUtilityCollectionFixture } from "./data/eldaruneUtilityCollectionData";
import saveUtilityItems from "./data/saveUtilityItems.json";
import saveTokenIdLevel from "./data/saveTokenIdLevel.json";
import { ExtendContract } from "../../utils/contractManager";
use(solidity)
describe("UtilityCollection", function () {
    let EldaruneUtilityBox = new ExtendContract("EldaruneUtilityBox", true);
    let EldaruneUtilityCollection = new ExtendContract("EldaruneUtilityCollection", true);
    let accounts: Array<SignerWithAddress>;
    const { getMintProgram, tokenUri } = EldaruneUtilityBoxFixture([]);
    const { openBoxProgram } = EldaruneUtilityCollectionFixture(null);
    const burn_role = "0xe97b137254058bd94f28d2f3eb79e2d34074ffb488d042e3bc958e0a57d2fa22";
    const minter_role = "0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6";

    describe("Item upgrade methods", function () {

        // beforeEach(async function () {
        //     accounts = await ethers.getSigners();
        //     const mintProgram = await getMintProgram();
        //     const eldaruneUtilityBox = await EldaruneUtilityBox.deploy([mintProgram, tokenUri]);
        //     await EldaruneUtilityCollection.deploy([openBoxProgram, saveUtilityItems, eldaruneUtilityBox]);
        // });

        it("Should be upgrade", async function () {
            const mintProgram = await getMintProgram();
            const eldaruneUtilityBoxAddress = await EldaruneUtilityBox.deploy([mintProgram, tokenUri]);
            await EldaruneUtilityCollection.deploy([openBoxProgram, saveUtilityItems, eldaruneUtilityBoxAddress]);
            const eldaruneUtilityBox = await EldaruneUtilityBox.contractInstance(true);
            const eldaruneUtilityCollection = await EldaruneUtilityCollection.contractInstance(true);

            // eldaruneUtilityBox.mintTest(100);
            
            // const eldaruneUtilityCollectionAddress = await EldaruneUtilityCollection.getContractAddress();
            // await eldaruneUtilityBox.grantRole(burn_role, eldaruneUtilityCollectionAddress);
            // await eldaruneUtilityBox.grantRole(minter_role, eldaruneUtilityCollectionAddress);

            console.log("Grant Roles ---------------");

            // await eldaruneUtilityCollection.saveTokenIdLevel(saveTokenIdLevel.splice(0, 500));
            // await eldaruneUtilityCollection.saveTokenIdLevel(saveTokenIdLevel.splice(500, 1000));
            
            // await eldaruneUtilityCollection.saveTokenIdLevel(saveTokenIdLevel.splice(1000, 1500));
            // await eldaruneUtilityCollection.saveTokenIdLevel(saveTokenIdLevel.splice(1500, 2000));
            // await eldaruneUtilityCollection.saveTokenIdLevel(saveTokenIdLevel.splice(2000, 2500));
            // await eldaruneUtilityCollection.saveTokenIdLevel(saveTokenIdLevel.splice(2500, 3000));
            // await eldaruneUtilityCollection.saveTokenIdLevel(saveTokenIdLevel.splice(3000, 3500));
            // await eldaruneUtilityCollection.saveTokenIdLevel(saveTokenIdLevel.splice(3500, 4000));
            // await eldaruneUtilityCollection.saveTokenIdLevel(saveTokenIdLevel.splice(4000, 4500));
            // await eldaruneUtilityCollection.saveTokenIdLevel(saveTokenIdLevel.splice(4500, 5000));

            console.log("saveTokenIdLevel ---------------");
            // const tokenIds = [];
            // const itemLevels = saveTokenIdLevel.filter(f => f.itemLevel == 1);

            // tokenIds.push(itemLevels[0].tokenId);
            // tokenIds.push(itemLevels[1].tokenId);
            
            // const result = await eldaruneUtilityCollection.upgradeNFT(tokenIds, { value: "6000000000000000" });
            // let eventFilter = eldaruneUtilityCollection.filters.NftUpgradeEvent();
            // if (eventFilter) {
            //     let events = await eldaruneUtilityCollection.queryFilter(eventFilter, result.blockNumber-10, 'latest');
            //     console.log(events);
            //     if (events) {
                    
            //         console.log("itemLevel:" + Number(events[0].args?.itemLevel));
            //         console.log("newTokenId:" + Number(events[0].args?.newTokenId));
            //     }
            // }
            
        });
    });
});