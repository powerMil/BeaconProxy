const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Lock", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployBeacon() {
    // Contracts are deployed using the first signer/account by default
    const [owner] = await ethers.getSigners();

    const BoxV1 = await ethers.getContractFactory("BoxV1");
    const boxV1 = await BoxV1.deploy();

    const Factory = await ethers.getContractFactory("Factory");
    const factory = await Factory.deploy(boxV1.target);

    return { owner, factory };
  }

  describe("Deployment", function () {
    it("Should upgrade the beacon contract", async function () {
      const { factory } = await loadFixture(deployBeacon);

      // Create two proxies      
      await factory.create("Box01", 5, 0);
      await factory.create("Box02", 10, 1);

      // Get first proxy information
      const box1Address = await factory.getBox(0);
      const newBox1 = await ethers.getContractFactory("BoxV1");
      const box01 = await newBox1.attach(box1Address);

      // Call function down()
      expect(await box01.value()).to.be.equal(5);
      await box01.down()
      expect(await box01.value()).to.be.equal(4);
      console.log("name: ", await box01.name());
      console.log("original value: ", await box01.value());

      // Get second proxy information
      const box2Address = await factory.getBox(1);
      const newBox2 = await ethers.getContractFactory("BoxV1");
      const box02 = await newBox2.attach(box2Address);

      // Call function down
      expect(await box02.value()).to.be.equal(10);
      await box02.down()
      expect(await box02.value()).to.be.equal(9);

      // Update the implementation contract
      const BoxV2 = await ethers.getContractFactory("BoxV2");
      const boxV2 = await BoxV2.deploy();

      // Use the Beacon instance
      const BoxBeacon = await ethers.getContractFactory("BoxBeacon");
      const beaconAddress = await factory.getBeacon();
      const boxBeacon = await BoxBeacon.attach(beaconAddress);

      // update implementation
      await expect(boxBeacon.update(boxV2.target)).not.to.be.reverted;

      // Call box01 using the new implementation
      const newBoxV2 = await ethers.getContractFactory("BoxV2");
      const box01V2 = await newBoxV2.attach(box1Address);

      // update the value --> 5
      await box01V2.up();
      console.log("name: ", await box01V2.name());
      console.log("new value: ", await box01V2.value())


    });
  });

});
