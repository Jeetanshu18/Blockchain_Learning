async function main() {
    const MyNFT = await ethers.getContractFactory("MyNFT");
  
    // Start deployment, returning a promise that resolves to a contract object
    const myNFT = await MyNFT.deploy();
    console.log("Contract deployed to address:", myNFT.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});

//0x1542ECEC7FaA1a227a93Ffd9AEC4AF45e9c85ce9