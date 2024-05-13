import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { BaseContract, BigNumber, Contract, EventFilter } from "ethers";
import { upgrades, ethers, hardhatArguments } from "hardhat";
import hardHatConfig from "../hardhat.config";
import { HardhatNetworkConfig, HttpNetworkUserConfig } from "hardhat/types";
const provider = ethers.provider;
const fs = require("fs").promises;
const defaultNetworkName: string = "localhost";

export interface NetworkDto {
  networkName: string;
  contracts: ContractDto[];
}

export interface ContractDto {
  name: string;
  address: string;
}

export const getProvider = () => {
  let _networkName = hardhatArguments.network;
  if (!_networkName) _networkName = defaultNetworkName;
  if (!hardHatConfig || !hardHatConfig.networks) {
    console.error("Hardhat config or networks not found");
    return;
  }
  const networkConfig = hardHatConfig.networks[
    _networkName
  ] as HttpNetworkUserConfig;

  if (networkConfig) {
    const provider = new ethers.providers.JsonRpcProvider(networkConfig.url);
    return provider;
  }
  console.error("Hardhat config or networks not found");
  return;
};

export const getLastBlockNumber = async () => {
  let blockNumber = 0;
  const provider = getProvider();
  if (provider) blockNumber = await provider.getBlockNumber();
  return blockNumber;
};

export const contractAddress = async (name: string): Promise<string | null> => {
  let networkDatas: NetworkDto[] = [];
  try {
    const data = await fs.readFile("configs/config.json", "utf8");
    networkDatas = JSON.parse(data);
    let _networkName = hardhatArguments.network;
    if (!_networkName) _networkName = defaultNetworkName;
    if (networkDatas.length > 0) {
      let network = networkDatas.find((f) => f.networkName == _networkName);
      let contract = network?.contracts.find((f) => f.name == name);
      if (contract) return contract.address;
    }
  } catch (ex: any) {
    console.log("--readJSON: " + ex);
  }
  return null;
};

export class ExtendContract {
  readonly name: string;
  private _configFileName: string = "configs/config.json";
  private _contractAddress: string | null;
  get address(): string | null {
    return this._contractAddress;
  }

  constructor(name: string) {
    this.name = name;
    this._contractAddress = null;
  }

  private async readJson(): Promise<NetworkDto[]> {
    let rtn: NetworkDto[] = [];
    try {
      const data = await fs.readFile(this._configFileName, "utf8");
      rtn = JSON.parse(data);
    } catch (ex: any) {
      console.log("--readJSON: " + ex);
    }
    return rtn;
  }

  private async getAbi(fileName: string): Promise<any> {
    let rtn: string = "";
    try {
      const data = await fs.readFile(
        "configs/abis/" + fileName + ".json",
        "utf8"
      );
      rtn = JSON.parse(data);
    } catch (ex: any) {
      console.log("--readJSON: " + ex);
    }
    return rtn;
  }

  async getImplementationAddress() {
    const provider = getProvider();
    const implementationKey = ethers.utils.id("implementation");
    let _networkName = hardhatArguments.network;
    if (!_networkName) _networkName = defaultNetworkName;
    const contractAddress = await this.getContractAddress(_networkName);
    if (provider && contractAddress) {
      const implementationAddress = await provider.getStorageAt(
        contractAddress,
        implementationKey
      );
      console.log("Implementation address:", implementationAddress);
    }
  }

  async setContractAddress(contractAddress: string) {
    this._contractAddress = contractAddress;
    let contractName: string = this.name;
    let networkDatas: NetworkDto[] = await this.readJson();
    let _networkName = hardhatArguments.network;
    if (!_networkName) _networkName = defaultNetworkName;
    if (!networkDatas || networkDatas.length == 0) {
      networkDatas.push({
        networkName: _networkName,
        contracts: [{ name: contractName, address: contractAddress }],
      });
    } else {
      let networkIndex = networkDatas.findIndex(
        (f) => f.networkName == _networkName
      );
      if (networkIndex > -1) {
        let contractIndex = networkDatas[networkIndex].contracts.findIndex(
          (f) => f.name == contractName
        );
        if (contractIndex > -1)
          networkDatas[networkIndex].contracts[contractIndex].address =
            contractAddress;
        else
          networkDatas[networkIndex].contracts.push({
            name: contractName,
            address: contractAddress,
          });
      } else
        networkDatas.push({
          networkName: _networkName,
          contracts: [{ name: contractName, address: contractAddress }],
        });
    }
    if (_networkName != "hardhat") {
      await fs.writeFile(
        this._configFileName,
        JSON.stringify(networkDatas, null, 4)
      );
    }
  }

  async getContractAddress(
    networkName: string | null = null
  ): Promise<string | null> {
    if (this._contractAddress != null) return this._contractAddress;
    let networkDatas: NetworkDto[] = await this.readJson();
    let _networkName = hardhatArguments.network;
    if (!_networkName) _networkName = defaultNetworkName;
    if (networkName) _networkName = networkName;
    let network = networkDatas.find((f) => f.networkName == _networkName);
    let contract = network?.contracts.find((f) => f.name == this.name);
    if (contract) return await contract.address;
    return await null;
  }

  async deploy(
    args: Array<any> = [],
    account: SignerWithAddress | null = null
  ): Promise<string | null> {
    try {
      let [owner] = await ethers.getSigners();
      let _account: SignerWithAddress;
      if (account != null) {
        _account = account;
      } else _account = owner;

      const ContractBase = await ethers.getContractFactory(this.name, _account);
      let contractBase: any;
      if (args.length > 0) contractBase = await ContractBase.deploy(...args);
      else contractBase = await ContractBase.deploy();
      await contractBase.deployed();
      this.setContractAddress(contractBase.address);
      console.log(this.name + " Deployed Address: " + contractBase.address);
      let _interface = JSON.parse(
        contractBase.interface.format("json") as string
      );
      let _interfaceEventOnly = _interface.filter(
        (m: any) => m.type === "event"
      );
      await fs.writeFile(
        "configs/abis/" + this.name + ".json",
        JSON.stringify(_interface, null, 4)
      );
      await fs.writeFile(
        "configs/abis/" + this.name + "_Graph.json",
        JSON.stringify(_interfaceEventOnly, null, 4)
      );
      return contractBase.address;
    } catch (ex: any) {
      console.log(this.name + " not deploy " + ex);
      return null;
    }
  }
  async deployUpgradeable(
    args: Array<any> = [],
    account: SignerWithAddress | null = null
  ): Promise<string | null> {
    let [owner] = await ethers.getSigners();
    let _account: SignerWithAddress;
    if (account != null) {
      _account = account;
    } else _account = owner;
    let proxyContractAddress = await this.getContractAddress();
    let contractBase = await this.upgrade(args, proxyContractAddress, _account);

    if (contractBase && contractBase.interface) {
      let _interface = JSON.parse(
        contractBase.interface.format("json") as string
      );
      let _interfaceEventOnly = _interface.filter(
        (m: any) => m.type === "event"
      );
      await fs.writeFile(
        "configs/abis/" + this.name + ".json",
        JSON.stringify(_interface, null, 4)
      );
      await fs.writeFile(
        "configs/abis/" + this.name + "_Graph.json",
        JSON.stringify(_interfaceEventOnly, null, 4)
      );
    }
    return contractBase.address;
  }
  async upgrade(
    args: Array<any> = [],
    proxyContractAddress: string | null = null,
    account: SignerWithAddress
  ): Promise<any> {
    try {
      const ContractBase = await ethers.getContractFactory(this.name, account);
      let contractBase: any;

      if (proxyContractAddress != null) {
        try {
          contractBase = await upgrades.upgradeProxy(
            proxyContractAddress,
            ContractBase
          );
        } catch (ex: any) {
          contractBase = await upgrades.forceImport(
            proxyContractAddress,
            ContractBase
          );
        }
      } else {
        try {
          contractBase = await upgrades.deployProxy(ContractBase, args);
        } catch (ex) {
          console.log("deployProxy", ex);
        }
      }
      await contractBase.deployed();
      this.setContractAddress(contractBase.address);
      console.log(
        this.name +
          (proxyContractAddress != null
            ? " Upgradable Address: "
            : " Proxy Address: ") +
          contractBase.address
      );

      return contractBase;
    } catch (ex: any) {
      console.log(this.name + " not deploy " + ex);
      return null;
    }
  }
  async contractInstance(
    isSigner: Boolean = false,
    account: SignerWithAddress | null = null,
    abi: any | null = null
  ) {
    const contractName = this.name;
    let contractAddress = this._contractAddress;
    if (contractAddress == null) {
      let networkDatas: NetworkDto[] = await this.readJson();
      let _networkName = hardhatArguments.network;
      if (!_networkName) _networkName = defaultNetworkName;
      let network = networkDatas.find((f) => f.networkName == _networkName);
      let contract = network?.contracts.find((f) => f.name == contractName);
      if (contract) contractAddress = contract.address;
    }

    if (contractAddress) {
      let contractInterface = null;
      if (abi) {
        contractInterface = abi;
      } else {
        contractInterface = await this.getAbi(this.name);
      }

      if (isSigner) {
        if (account != null)
          return await new ExtendedContract(
            contractAddress,
            contractInterface,
            account
          );
        else {
          const [owner] = await ethers.getSigners();
          return await new ExtendedContract(
            contractAddress,
            contractInterface,
            owner
          );
        }
      } else
        return await new ExtendedContract(contractAddress, contractInterface);
    }
    throw Error("Not find Contract!!!");
  }

  async contractInstanceByAbi(isSigner: Boolean = false, abi: any) {
    const contractName = this.name;
    let contractAddress = this._contractAddress;
    if (contractAddress == null) {
      let networkDatas: NetworkDto[] = await this.readJson();
      let _networkName = hardhatArguments.network;
      if (!_networkName) _networkName = defaultNetworkName;
      let network = networkDatas.find((f) => f.networkName == _networkName);
      let contract = network?.contracts.find((f) => f.name == contractName);
      if (contract) contractAddress = contract.address;
    }
    if (contractAddress) {
      if (isSigner) {
        const [owner] = await ethers.getSigners();
        return await new ExtendedContract(contractAddress, abi, owner);
      } else return await new ExtendedContract(contractAddress, abi);
    }
    throw Error("Not find Contract!!!");
  }
}

export class ExtendedContract extends Contract {
  async getEventArgs(result: any, eventName: string): Promise<any> {
    let rtn = [];
    let eventFilter = this.filters[eventName]();
    if (result && eventFilter) {
      let events = await this.queryFilter(
        eventFilter,
        result.blockNumber,
        result.blockNumber
      );
      console.log(events.length);
      if (events) {
        rtn = events.map((x: any) => x.args);
      }
    }
    return rtn;
  }
  async getEstimatedGasLimit(
    functionName: string,
    args?: Array<any>,
    from?: string
  ): Promise<BigNumber> {
    const functionData = this.interface.encodeFunctionData(functionName, args);
    let tx = {
      from: "",
      to: this.address,
      data: functionData,
    };
    if (from) {
      tx.from = from;
    }
    return await provider.estimateGas(tx);
  }
  async estimatedGas(
    functionName: string,
    args?: Array<any>,
    from?: string
  ): Promise<void> {
    const functionData = this.interface.encodeFunctionData(functionName, args);
    let tx = {
      from: "",
      to: this.address,
      data: functionData,
    };
    if (from) {
      tx.from = from;
    }
    const gasLimit = await provider.estimateGas(tx);
    const gasPrice = await provider.getGasPrice();
    const gasCost = ethers.utils.formatEther(gasLimit.mul(gasPrice));
    console.log(`${functionName} Gas: ${gasPrice} gwei`);
    console.log(`${functionName} Gas Limit: ${gasLimit} ether`);
    console.log(`${functionName} Estimated gas: ${gasCost} ether`);
  }
}
