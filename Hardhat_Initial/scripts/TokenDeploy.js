async function main() {
  [owner] = await ethers.getSigners();

  Instance = await ethers.getContractFactory("MockToken");
  Token = await Instance.deploy();

  console.log("Token Deployed at: ", Token.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
