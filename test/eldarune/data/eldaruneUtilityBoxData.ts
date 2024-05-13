import { MerkleTree } from "merkletreejs";
import keccak256 from "keccak256";
import axios from 'axios';
import { getProvider } from "../../../utils/contractManager";
import { ethers } from "ethers";
import setTokensURI from './setTokensURI.json';

export interface MintProgram {
    whiteListEnabled: boolean,
    merkleRoot: string,
    startDate: number,
    mintEnabled: boolean
};

export function EldaruneUtilityBoxFixture(whiteList: Array<string>) {


    const tokenUri = "UtilityBox.json";

    const getWhiteList = async () => {
        //const result = await axios.get<string[]>('https://mint.digard.io/eldarune/utility-box/whitelist/whitelist.json');
        return ["0xbe0CF71aeD2d4F1A427396B3a13Cab47351f29C2"];
    };

    const padBuffer = (addr: any) => {
        return Buffer.from(addr.substr(2).padStart(32 * 2, 0), 'hex');
    };

    const getMerkleRoot = async () => {
        if (whiteList.length == 0) whiteList = await getWhiteList();
        console.log(whiteList.length);
        const leaves = whiteList.map((account: string) => padBuffer(account));
        let tree = new MerkleTree(leaves, keccak256, { sort: true });
        return tree.getHexRoot();
    };

    const getMintProgram = async () => {

        return {
            whiteListEnabled: true,
            merkleRoot: "0x",
            startDate: (Date.UTC(2023, 3, 20, 16, 20, 0) / 1000),
            mintEnabled: true
        }
    }

    const getWhiteListMerkleTreeProofHash = async (_account: String) => {
        if (whiteList.length == 0) whiteList = await getWhiteList();
        const leaves = whiteList.map((acc) => padBuffer(acc));
        const tree = new MerkleTree(leaves, keccak256, { sort: true });
        const merkleRoot = tree.getHexRoot();
        let merkleProof = tree.getHexProof(padBuffer(_account));
        return merkleProof;
    }
    const toEtherFormat = (inputVal: any, decimals: number, formatFixed: number): string => {
        try {
            inputVal = ethers.utils.formatUnits(inputVal, decimals);
            inputVal = Number(inputVal);
            if (Number.isInteger(inputVal)) {
                return inputVal.toLocaleString();
            }
            return inputVal.toFixed(formatFixed).toLocaleString();
        } catch (ex: any) {
            return "0";
        }
    }
    const balanceControl = async () => {
        
        const whiteList = await getWhiteList();
        const provider = getProvider();
        if (provider) {
            let totalZeroAboveAddress = 0;
            for (let i = 0; i < whiteList.length; i++) {
                try {
                    const address = whiteList[i];
                    const balance = await provider.getBalance(address);
                    const balanceEther = ethers.utils.formatEther(balance);
                    //balanceList[address] = balanceEther;
                    if (balance.gt(ethers.utils.parseEther('0.01'))) {
                        totalZeroAboveAddress++;
                    }
                    console.log("Completed: " + i);
                } catch {
                    continue;
                }
                
            }
            console.log('Total zero above address > 0.01 ETH:', totalZeroAboveAddress);

        }

    }
    const getTokenIds = async ()=> {
        let tokenIds = [];
        for(var i=0; i < setTokensURI.length; i++) {
            tokenIds.push(setTokensURI[i][0]);
        }
        return tokenIds;
    }
    const getTokenUris = async ()=> {
        let tokenUris = [];
        for(var i=0; i < setTokensURI.length; i++) {
            tokenUris.push(setTokensURI[i][1]);
        }
        return tokenUris;
    }

    return { balanceControl, getMintProgram, tokenUri, getWhiteListMerkleTreeProofHash, getMerkleRoot, getTokenIds, getTokenUris }
}

