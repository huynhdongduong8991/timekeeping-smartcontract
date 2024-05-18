require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: "https://sepolia.infura.io/v3/a48f85d0e5104c3493411446bb12fd6d",
      chainId: 11155111,
      accounts: ["8868549285dcb9f8157a3cc6961b33b5ece3dce52eca27fd0752cf5eaf43555a"]
    },
  }
};
