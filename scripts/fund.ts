import { ethers, getNamedAccounts } from "hardhat";

async function main() {
  const { deployer } = await getNamedAccounts();
  const fundMe = await ethers.getContract("FundMe", deployer);
  const txResponse = await fundMe.fund({
    value: ethers.utils.parseEther("0.3"),
  });
  await txResponse.wait(1);
  console.log("FUNDED!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
