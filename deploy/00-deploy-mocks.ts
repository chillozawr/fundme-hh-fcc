import { DeployFunction } from "hardhat-deploy/types";
import {
  developmentChains,
  DECIMALS,
  INITIAL_PRICE,
} from "../helper-hardhat-config";
import { HardhatRuntimeEnvironment } from "hardhat/types";

const deployMocks: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { getNamedAccounts, deployments, network } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId: number = network.config.chainId!;

  if (developmentChains.includes(network.name)) {
    log("Local network detected! Deploying mocks...");
    await deploy("MockV3Aggregator", {
      contract: "MockV3Aggregator",
      from: deployer,
      log: true,
      args: [DECIMALS, INITIAL_PRICE],
    });
    log("Mocks deployed!");
    log("----------------------------------");
  }
};

export default deployMocks;
deployMocks.tags = ["all", "mocks"];
