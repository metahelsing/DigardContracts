import { ethers } from "hardhat";
import { expect, use } from "chai";
import { solidity } from "ethereum-waffle";
import { ExtendContract } from "../../utils/contractManager";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
use(solidity)
describe("UtilityStake", function () {
    let EldaruneUtilityStake = new ExtendContract("EldaruneUtilityStaking", true);
    let accounts: Array<SignerWithAddress>;
    describe("Staking Process", function() {
        beforeEach(async function () {
            accounts = await ethers.getSigners();
            // const mintProgram = await getMintProgram();
            // const eldaruneUtilityBox = await EldaruneUtilityBox.deploy([mintProgram, tokenUri]);
            // await EldaruneUtilityStake.deploy([openBoxProgram, saveUtilityItems, eldaruneUtilityBox]);
        });
        it("", async function (){

        });
    });
});