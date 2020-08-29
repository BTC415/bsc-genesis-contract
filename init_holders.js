const web3 = require("web3")
const init_holders = [
  {
     address: "0xb005741528b86F5952469d80A8614591E3c5B632",
     balance: web3.utils.toBN("500000000000000000000").toString("hex") // 500e18
  },
  {
     address: "0x446AA6E0DC65690403dF3F127750da1322941F3e",
     balance: web3.utils.toBN("500000000000000000000").toString("hex") // 500e18
   }
];


exports = module.exports = init_holders
