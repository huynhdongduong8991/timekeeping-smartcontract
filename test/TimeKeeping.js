const { ethers } = require("hardhat");
const { expect } = require("chai");
const { timestampToDate } = require("../util/TimeHelper");

describe("Test create employee in TimeKeeping contract", function () {
  let timeKeepingContract;
  this.beforeEach(async () => {
    timeKeepingContract = await ethers.deployContract("TimeKeepingContract");
  });

  it("Should create employee successfully", async function () {
    const [_, signer1] = await ethers.getSigners();

    const employeeID = signer1.address;
    const name = "John Doe";
    const badgeID = "12345";

    await timeKeepingContract.setEmployee([employeeID, name, badgeID]);

    const employeeResponse = await timeKeepingContract.mAttendant(employeeID);

    expect(employeeResponse.employeeID).to.equal(employeeID);
    expect(employeeResponse.name).to.equal(name);
    expect(employeeResponse.badgeID).to.equal(badgeID);
  });

  it("Should create employee fail when account is not admin", async function () {
    const [_, signer1] = await ethers.getSigners();

    const employeeID = signer1.address;
    const name = "John Doe";
    const badgeID = "12345";

    await expect(
      timeKeepingContract
        .connect(signer1)
        .setEmployee([employeeID, name, badgeID])
    ).to.be.revertedWith("You are not allow");
  });
});

describe("Test create employee in TimeKeeping contract", function () {
  let timeKeepingContract;
  let employeeID, name, badgeID;
  let employee;

  this.beforeEach(async () => {
    timeKeepingContract = await ethers.deployContract("TimeKeepingContract");
    const [_, signer1] = await ethers.getSigners();

    employeeID = signer1.address;
    name = "John Doe";
    badgeID = "12345";
    await timeKeepingContract.setEmployee([employeeID, name, badgeID]);
    employee = await timeKeepingContract.mAttendant(signer1.address);
  });

  it("Should checkin successfully", async () => {
    const [_, signer1] = await ethers.getSigners();

    await timeKeepingContract.connect(signer1).recordAttendance(0);

    const { year, month, day } = timestampToDate(new Date().getTime() / 1000);
    const recordHistory = await timeKeepingContract.mHistory(
      employeeID,
      year,
      month,
      day
    );

    expect(recordHistory.employeeID).to.equal(employeeID);
    expect(recordHistory.checkinTime).not.to.equal(0);
  });

  it("Should checkout successfully", async () => {
    const [_, signer1] = await ethers.getSigners();

    await timeKeepingContract.connect(signer1).recordAttendance(0);

    await timeKeepingContract.connect(signer1).recordAttendance(1);

    const { year, month, day } = timestampToDate(new Date().getTime() / 1000);
    const recordHistory = await timeKeepingContract.mHistory(
      employeeID,
      year,
      month,
      day
    );

    expect(recordHistory.employeeID).to.equal(employeeID);
    expect(recordHistory.checkoutTime).not.to.equal(1);
  });

  it("Should return error when checkout without checkin", async () => {
    const [_, signer1] = await ethers.getSigners();

    await expect(
      timeKeepingContract.connect(signer1).recordAttendance(1)
    ).to.be.revertedWith("User has not yet checked in");
  });

  it("Should return error when already checkin", async () => {
    const [_, signer1] = await ethers.getSigners();

    await timeKeepingContract.connect(signer1).recordAttendance(0);
    await expect(
      timeKeepingContract.connect(signer1).recordAttendance(0)
    ).to.be.revertedWith("User already checked in");
  });

  it("Should return error when checkout without checkin", async () => {
    const [_, signer1] = await ethers.getSigners();

    await timeKeepingContract.connect(signer1).recordAttendance(0);
    await timeKeepingContract.connect(signer1).recordAttendance(1);
    await expect(
      timeKeepingContract.connect(signer1).recordAttendance(1)
    ).to.be.revertedWith("User already checked out");
  });

});
