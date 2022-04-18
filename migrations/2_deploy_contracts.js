const ReEntrancy = artifacts.require("ReEntrancy");
const Attack = artifacts.require("Attack");

module.exports = function (deployer) {
  deployer.deploy(ReEntrancy).then(function() {
    return deployer.deploy(Attack, ReEntrancy.address);
  });
};
