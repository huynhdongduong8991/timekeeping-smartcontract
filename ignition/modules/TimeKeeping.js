const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("TimeKeepingModule", (m) => {
  const deployed = m.contract("TimeKeepingContract");

  return { deployed };
});
