const ReEntrancy = artifacts.require("ReEntrancy");
const Attack = artifacts.require("Attack");

module.exports = function (deployer) {
  deployer.deploy(ReEntrancy);
  deployer.deploy(Attack);
};
