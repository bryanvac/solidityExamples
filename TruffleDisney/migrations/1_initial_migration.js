const Disney = artifacts.require("Disney");

module.exports = function (deployer) {
  deployer.deploy(Disney);
};
