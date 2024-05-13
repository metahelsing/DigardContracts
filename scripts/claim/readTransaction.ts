import { ethers } from "hardhat";
import { ExtendContract } from "../../utils/contractManager";
const readline = require("readline");

async function main() {
  const DigardClaim = new ExtendContract("DigardClaim");
  const digardClaim = await DigardClaim.contractInstance(true);
  const provider = ethers.provider;
  const transactionHash: string =
    "0x402c742252c3a4b72a3181375b28324ef092d6c14344a418b41d140d88e71cf6";

  try {
    async function getTransactionLogs(provider: any, transactionHash: any) {
      // İşlem (transaction) nesnesini al
      const transaction = await provider.getTransaction(transactionHash);

      // Event ismi
      const eventName = "PlayerNftClaimed";

      // Eventin kontrattaki konumu (topic)
      const eventTopic = digardClaim.interface.getEventTopic(eventName);

      // Filter objesini oluştur
      const filter = {
        address: transaction.to,
        topics: [eventTopic],
      };

      // Logs'u al
      const logs = await provider.getLogs(filter);
      console.log(logs);
      // Logs üzerinde işlemlerinizi gerçekleştirin
      logs.forEach((log: any) => {
        const parsedLog: any = digardClaim.interface.parseLog(log);
        console.log("Event:", parsedLog.name);
        console.log("Data:", parsedLog.values);
        // Daha fazla işlem kodları buraya eklenebilir
      });

      return logs;
    }
    getTransactionLogs(provider, transactionHash)
      .then((logs) => console.log("Logs:", logs))
      .catch((error) => console.error("Error:", error));
  } catch (ex) {
    console.log(ex);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
