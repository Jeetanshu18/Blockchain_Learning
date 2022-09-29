const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token Contract", () => {
  let Instance;
  let Token;
  let owner;
  let user1;
  let user2;
  let user3;
  let addrs;

  beforeEach(async function () {
    [owner, user1, user2, user3, ...addrs] = await ethers.getSigners();

    Instance = await ethers.getContractFactory("MockToken");
    Token = await Instance.deploy();
  });

  describe("Deployment", function () {
    it("Should set a name", async function () {
      expect(await Token.name()).to.equal("Mock Token");
    });

    it("Should set a symbol", async function () {
      expect(await Token.symbol()).to.equal("mToken");
    });

    it("Shoud set the token supply", async function () {
      expect(await Token.totalSupply()).to.equal(
        "1000000000000000000000000000"
      );
    });

    it("Should give total supply to owner", async function () {
      expect(await Token.balanceOf(owner.address)).to.equal(
        "1000000000000000000000000000"
      );
    });
  });

  describe("Transfer Test", function () {
    it("Should fail to transfer (do not have enough balance)", async function () {
      await expect(
        Token.connect(user1).transfer(user2.address, "1000000000000000000")
      ).to.be.revertedWith("insufficient balance");
    });

    it("Should successfully transfer", async function () {
      await Token.transfer(user1.address, "1000000000000000000");

      expect(await Token.balanceOf(user1.address)).to.equal(
        "1000000000000000000"
      );
    });
  });

  describe("Approval/TransferFrom Test", function () {
    it("Should approve", async function () {
      await Token.approve(user1.address, "1000000000000000000");
      expect(await Token.allowance(owner.address, user1.address)).to.equal(
        "1000000000000000000"
      );
    });

    it("Should fail to transfer from user1 to user2 (insufficient balance)", async function () {
      await Token.connect(user1).approve(owner.address, "1000000000000000000");

      await expect(
        Token.transferFrom(user1.address, user2.address, "100000000")
      ).to.be.revertedWith("insufficient balance");
    });

    it("Should fail to transfer from user1 to user2 (not allowed to transfer)", async function () {
      await Token.transfer(user1.address, "1000000000000000000");
      await expect(
        Token.transferFrom(user1.address, user2.address, "100000000")
      ).to.be.revertedWith("not allowed to transfer");
    });

    it("Should successfully transfer from user1 to user2", async function () {
      await Token.transfer(user1.address, "1000000000000000000");

      await Token.connect(user1).approve(owner.address, "1000000000000000000");
      await Token.transferFrom(user1.address, user2.address, "100000000");

      expect(await Token.balanceOf(user2.address)).to.equal("100000000");
    });
  });
});