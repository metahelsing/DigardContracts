import { convertToWei } from "../../../utils/helpers";
//const eldaruneUtilityCollectionWhiteList = require('../../../configs/eldaruneUtilityCollectionWhiteList.json');

export interface OpenBoxProgram {
    startDate: number,
    openBoxEnabled: boolean
};

export interface UtilityItem {
    itemId: number,
    tokenId: BigInt,
    itemLevel: number,
    chancePercent: number,
    upgradeFee: BigInt
}

export interface WhiteListChanceMultiplier {
    tokenId: BigInt,
    chanceRateIncreaseMultiplier: number
}

export interface AddressWhiteListChanceMultiplier {
    address: string,
    whiteListChanceMultipliers: WhiteListChanceMultiplier[]
}

export function EldaruneUtilityCollectionFixture(whiteList: Array<string>|null) {
    //const __whiteList:Array<string> = eldaruneUtilityCollectionWhiteList;
    
    const openBoxProgram:OpenBoxProgram = {
        startDate: (Date.UTC(2023, 1, 25, 13, 0, 0)/1000),
        openBoxEnabled: true
    };
    
    
    
    
    return {openBoxProgram}
}

