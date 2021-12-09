const { ethers } = require("hardhat");

async function main() {
  const Betting = await ethers.getContractFactory("Betting");
  const betting = await Betting.deploy(48);
  await betting.deployed();
  console.log("Success! Contract was deployed to: ", betting.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
