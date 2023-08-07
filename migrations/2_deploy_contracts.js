// File: migrations/2_deploy_contracts.js
const University = artifacts.require("University");
const DCS = artifacts.require("DCS");
const CUE = artifacts.require("CUE");
const KNQA = artifacts.require("KNQA");
const DigitalCertificateSystem = artifacts.require("DigitalCertificateSystem");

module.exports = async function (deployer) {
  // Deploy University contract
  await deployer.deploy(University);
  const university = await University.deployed();

  // Deploy DCS contract with University address as constructor argument
  await deployer.deploy(DCS, university.address);
  const dcs = await DCS.deployed();

  // Deploy CUE contract with DCS address as constructor argument
  await deployer.deploy(CUE, dcs.address);

  // Deploy KNQA contract with DCS address as constructor argument
  await deployer.deploy(KNQA, dcs.address);

  // Deploy DigitalCertificateSystem contract with DCS address as constructor argument
  await deployer.deploy(DigitalCertificateSystem, dcs.address);
};
