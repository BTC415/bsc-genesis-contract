const web3 = require("web3")
const RLP = require('rlp');

// Configure
const validators = [
  
   {
     "consensusAddr": "0x2a7cdd959bFe8D9487B2a43B33565295a698F7e2",
     "feeAddr": "0x1ff80f3f7f110ffd8920a3ac38fdef318fe94a3f",
     "bscFeeAddr": "0xB6a7eDd747C0554875d3Fc531d19bA1497992c5E",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0x6488Aa4D1955Ee33403f8ccB1d4dE5Fb97C7ade2",
     "feeAddr": "0x1a87e90e440a39c99aa9cb5cea0ad6a3f0b2407b",
     "bscFeeAddr": "0x220F003d8bDfaADf52AA1e55ae4cc485e6794875",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0x9ef9f4360c606c7AB4db26b016007d3ad0aB86a0",
     "feeAddr": "0x18e2db06cbff3e3c5f856410a1838649e7601757",
     "bscFeeAddr": "0x6103Af86a874B705854033438383C82575f25bc2",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0xEe01C3b1283AA067C58eaB4709F85e99D46de5FE",
     "feeAddr": "0x15904ab26ab0e99d70b51c220ccdcccabee6e297",
     "bscFeeAddr": "0xEE4B9bFb1871c64E2BcAbB1dc382DC8B7C4218A2",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0x685B1ded8013785d6623CC18D214320b6Bb64759",
     "feeAddr": "0x13e39085dc88704f4394d35209a02b1a9520320c",
     "bscFeeAddr": "0xa20Ef4E5E4e7E36258dbF51f4D905114CB1B34Bc",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0x78f3aDfC719C99674c072166708589033e2d9afe",
     "feeAddr": "0x055838358c29edf4dcc1ba1985ad58aedbb6be2b",
     "bscFeeAddr": "0x48a30D5eAa7b64492A160F139E2DA2800eC3834e",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0xc2Be4EC20253B8642161bC3f444F53679c1F3D47",
     "feeAddr": "0xd1d678a2506eeaa365056fe565df8bc8659f28b0",
     "bscFeeAddr": "0x66F50c616d737e60d7CA6311ff0D9c434197898A",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0x2f7bE8361C80A4c1e7e9aAF001d0877F1CFdE218",
     "feeAddr": "0xecbc4fb1a97861344dad0867ca3cba2b860411f0",
     "bscFeeAddr": "0x5F93992aC37F3e61db2Ef8a587A436A161FD210b",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0xce2FD7544e0B2Cc94692d4A704deBEf7bcB61328",
     "feeAddr": "0x8acc2ab395ded08bb75ce85bf0f95ad2abc51ad5",
     "bscFeeAddr": "0x44ABc67B4b2Fba283c582387f54c9cbA7C34baFa",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0xB8f7166496996A7da21cF1f1b04d9B3E26a3d077",
     "feeAddr": "0x882d745ed97d4422ca8da1c22ec49d880c4c0972",
     "bscFeeAddr": "0x6770572763289aaC606e4f327C2F6CC1aA3b3e3B",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0x2D4C407BBe49438ED859fe965b140dcF1aaB71a9",
     "feeAddr": "0xb2bbb170ca4e499a2b0f3cc85ebfa6e8c4dfcbea",
     "bscFeeAddr": "0x3aD0939e120F33518fBBA04631AfE7a3eD6327b1",
     "votingPower": 0x0000048c27395000,
   },
   {
     "consensusAddr": "0x6BBad7Cf34b5fA511d8e963dbba288B1960E75D6",
     "feeAddr": "0x42498946a51ca5924552ead6fc2af08b94fcba64",
     "bscFeeAddr": "0x853b0f6c324D1f4e76C8266942337AC1B0AF1a22",
     "votingPower": 0x000001d1a94a2000,
   },
   {
     "consensusAddr": "0x4430b3230294D12c6AB2aAC5C2cd68E80B16b581",
     "feeAddr": "0x795811a7f214084116949fc4f53cedbf189eeab2",
     "bscFeeAddr": "0x7b107f4976a252a6939b771202C28E64e03f52D6",
     "votingPower": 0x000001d1a94a2000,
   },
   {
     "consensusAddr": "0xea0A6E3c511bbD10f4519EcE37Dc24887e11b55d",
     "feeAddr": "0x64feb7c04830dd9ace164fc5c52b3f5a29e5018a",
     "bscFeeAddr": "0x6811CA77ACFb221a49393c193f3a22DB829FCc8E",
     "votingPower": 0x000001d1a94a2000,
   },
   {
     "consensusAddr": "0x7AE2F5B9e386cd1B50A4550696D957cB4900f03a",
     "feeAddr": "0x64e48d4057a90b233e026c1041e6012ada897fe8",
     "bscFeeAddr": "0xE83BCc5077E6b873995C24bAc871b5ad856047E1",
     "votingPower": 0x000001d1a94a2000,
   },
   {
     "consensusAddr": "0x82012708DAfC9E1B880fd083B32182B869bE8E09",
     "feeAddr": "0x28b383d324bc9a37f4e276190796ba5a8947f5ed",
     "bscFeeAddr": "0x8e5adc73a2D233a1b496ED3115464dd6c7b88750",
     "votingPower": 0x000001d1a94a2000,
   },
   {
     "consensusAddr": "0x22B81f8E175FFde54d797FE11eB03F9E3BF75F1d",
     "feeAddr": "0x2767f7447f7b9b70313d4147b795414aecea5471",
     "bscFeeAddr": "0xa1C3Ef7cA38d8bA80cCe3BFc53EBd2903Ed21658",
     "votingPower": 0x000001d1a94a2000,
   },
   {
     "consensusAddr": "0x68Bf0B8b6FB4E317a0f9D6F03eAF8CE6675BC60D",
     "feeAddr": "0xd84f0d2e50bcf00f2fc476e1c57f5ca2d57f625b",
     "bscFeeAddr": "0x675cfe570b7902623F47e7f59C9664b5F5065DcF",
     "votingPower": 0x000001d1a94a2000,
   },
   {
     "consensusAddr": "0x8c4D90829CE8F72D0163c1D5Cf348a862d550630",
     "feeAddr": "0xcc2cedc53f0fa6d376336efb67e43d167169f3b7",
     "bscFeeAddr": "0x85C42a7B34309bee2ed6A235f86D16F059Deec58",
     "votingPower": 0x000001d1a94a2000,
   },
   {
     "consensusAddr": "0x35E7a025f4da968De7e4D7E4004197917F4070F1",
     "feeAddr": "0xc4fd0d870da52e73de2dd8ded19fe3d26f43a113",
     "bscFeeAddr": "0xb1182abAEeB3B4d8EBa7e6a4162eaC7AcE23D573",
     "votingPower": 0x000001d1a94a2000,
   },
   {
     "consensusAddr": "0xd6caA02BBebaEbB5d7e581e4B66559e635F805fF",
     "feeAddr": "0xefaff03b42e41f953a925fc43720e45fb61a1993",
     "bscFeeAddr": "0xc07335Cf083C1c46A487f0325769D88e163b6536",
     "votingPower": 0x000001d1a94a2000,
   },
];

// ===============  Do not edit below ====
function generateExtradata(validators) {
  let extraVanity =Buffer.alloc(32);
  let validatorsBytes = extraDataSerialize(validators);
  let extraSeal =Buffer.alloc(65);
  return Buffer.concat([extraVanity,validatorsBytes,extraSeal]);
}

function extraDataSerialize(validators) {
  let n = validators.length;
  let arr = [];
  for (let i = 0;i<n;i++) {
    let validator = validators[i];
    arr.push(Buffer.from(web3.utils.hexToBytes(validator.consensusAddr)));
  }
  return Buffer.concat(arr);
}

function validatorUpdateRlpEncode(validators) {
  let n = validators.length;
  let vals = [];
  for (let i = 0;i<n;i++) {
    vals.push([
      validators[i].consensusAddr,
      validators[i].bscFeeAddr,
      validators[i].feeAddr,
      validators[i].votingPower,
    ]);
  }
  let pkg = [0x00, vals];
  return web3.utils.bytesToHex(RLP.encode(pkg));
}

extraValidatorBytes = generateExtradata(validators);
validatorSetBytes = validatorUpdateRlpEncode(validators);

exports = module.exports = {
  extraValidatorBytes: extraValidatorBytes,
  validatorSetBytes: validatorSetBytes,
}