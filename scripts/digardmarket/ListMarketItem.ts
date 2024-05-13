import { ethers } from "hardhat";
import {ContractInfo} from "../constants";
const readline = require('readline')

async function main() 
{
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout })

  const question = (prompt: string) => { return new Promise((resolve, reject) => { rl.question(prompt, resolve) }) }

  (async () => {
        const index = await question('Start Index?')
        const [owner] = await ethers.getSigners();
        const DigardGameMarketAddress = await ContractInfo.getContractAddress("DigardGameMarket");
        const DigardGameMarketAbi = await (await ethers.getContractFactory("DigardGameMarket")).interface;
        const DigardGameMarketInterface = await new ethers.Contract(DigardGameMarketAddress, DigardGameMarketAbi, owner);
        const EldaTokenAddress = ContractInfo.getContractAddress("EldaToken");
        const EldaruneSeason1Address = ContractInfo.getContractAddress("EldaruneSeason1");
        const errorCounter = {index: 0, tokenId: 0};
        try {
            let price = 100;
            const start = (i: number)=> {
              console.log(i);
              switch (i){
                case 1:
                case 11:
                case 21:
                case 31:
                case 41:
                case 51:
                case 61:
                case 71:
                case 81:
                  price = 100;
                break;
                case 2:
                case 12:
                case 22:
                case 32:
                case 42:
                case 52:
                case 62:
                case 72:
                case 82:
                  price = 250;
                break;
                case 3:
                case 13:
                case 23:
                case 33:
                case 43:
                case 53:
                case 63:
                case 73:
                case 83:
                  price = 500;
                break;
                case 4:
                case 14:
                case 24:
                case 34:
                case 44:
                case 54:
                case 64:
                case 74:
                case 84:
                  price = 750;
                break;
                case 5:
                  case 15:
                  case 25:
                  case 35:
                  case 45:
                  case 55:
                  case 65:
                  case 75:
                  case 85:
                    price = 1000;
                  break;
                  case 6:
                  case 16:
                  case 26:
                  case 36:
                  case 46:
                  case 56:
                  case 66:
                  case 76:
                  case 86:
                    price = 1250;
                  break;
                  case 7:
                  case 17:
                  case 27:
                  case 37:
                  case 47:
                  case 57:
                  case 67:
                  case 77:
                  case 87:
                    price = 1500;
                  break;
                  case 8:
                    case 18:
                    case 28:
                    case 38:
                    case 48:
                    case 58:
                    case 68:
                    case 78:
                    case 88:
                      price = 1750;
                    break;
                    case 9:
                    case 19:
                    case 29:
                    case 39:
                    case 49:
                    case 59:
                    case 69:
                    case 79:
                    case 89:
                      price = 2000;
                    break;
                    case 10:
                    case 20:
                    case 30:
                    case 40:
                    case 50:
                    case 60:
                    case 70:
                    case 80:
                    case 90:
                      price = 2500;
                      break;
                    case 94:
                    case 97:
                      price = 5000;
                      break;
                    case 93:
                    case 95:
                      price = 7500;
                      break;
                    case 91:
                    case 92:
                    case 96:
                    case 98:
                    case 99:
                    case 100:
                    case 101:
                    case 102:
                    case 103:
                    case 104:
                    case 105:
                    case 106:
                    case 107:
                      price = 10000; 
                      break;
                    default:
                      price = 0;
                    break;
            }
            if(price > 0) {
              DigardGameMarketInterface.ListMarketItem(EldaruneSeason1Address, i, EldaTokenAddress, ethers.utils.parseEther(String(price)), 0, false).then(()=> {
                console.log("ListMarketItem Successfuly " + i);
                setTimeout(function(){
                  DigardGameMarketInterface.getMarketIdByTokenId(i).then((res:any)=> {
                        const marketId = Number(res);
                        console.log("MarketId: " + marketId + " TokenId: " + i);
                        if(marketId > 0) start(i+1);
                        else start(i);
                  });
                  
                }, 3000);
                
              }).catch(()=> {
                console.log("ListMarketItem Error Token Id:" + i);
                errorCounter.index++;
                errorCounter.tokenId = i;
                if(errorCounter.index < 9) {
                    start(i);
                } else {
                  start(i+1);
                }
                
              });
            }
             
            }
            start(Number(index));
            
        } catch (ex){
            console.log(ex);
        }
        rl.close()
    })()
  }
  
  main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });