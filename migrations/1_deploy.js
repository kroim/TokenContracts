let BIGFOOT = artifacts.require("BIGFOOT");

module.exports = function(deployer) {
    // bsctestnet
    // let _routerAddress = "0xEE33a3e4ABC26b1eb524225707B0d017576d8a6c";
    // let _bananaAddress = "0x3331b6b64bFaC234998b20BD38f606998D2E787A";
    // bscmainnet
    let _routerAddress = '0xcF0feBd3f17CEf5b47b0cD257aCf6025c5BFf3b7';
    let _bananaAddress = '0x603c7f932ED1fc6575303D8Fb018fDCBb0f39a95';
    deployer.deploy(BIGFOOT, _routerAddress, _bananaAddress);
}


