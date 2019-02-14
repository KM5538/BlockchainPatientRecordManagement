/*var Election = artifacts.require("./Election.sol");

module.exports = function(deployer) {
  deployer.deploy(Election);
};*/

var project = artifacts.require("./Project.sol");

module.exports = function(deployer) {
  deployer.deploy(project);
};
