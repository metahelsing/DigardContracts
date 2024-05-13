import { ethers } from "ethers";
export const convertToWei = (value: number, decimals: number|null=null): string=> {
    if(decimals == null) decimals = 18;
    let priceWei = Number(value) * 10 ** decimals;
    return priceWei.toString();
}
export const addMinutes =  (dt:Date, minutes:number):Date=>{
    return new Date(dt.getTime() + minutes*60000);
}

export const newLineToArray = (str: string):Array<string>=> {
    let arr = str.split('\n');
    arr = arr.map((walletAddress)=> {
       return walletAddress.replace(/\s/g,'');
    });
    return arr;
}
