const program = require("commander");
const fs = require("fs");
const nunjucks = require("nunjucks");


program.version("0.0.1");
program.option(
    "-t, --template <template>",
    "TendermintLightClient template file",
    "./contracts/TendermintLightClient.template"
);

program.option(
    "-o, --output <output-file>",
    "TendermintLightClient.sol",
    "./contracts/TendermintLightClient.sol"
)

program.option("--rewardForValidatorSetChange <rewardForValidatorSetChange>",
    "rewardForValidatorSetChange",
    "1e16"); //1e16

program.option("--initConsensusStateBytes <initConsensusStateBytes>",
    "init consensusState bytes, hex encoding, no prefix with 0x",
    "42696e616e63652d436861696e2d5469677269730000000000000000000000000000000006915167cedaf7bbf7df47d932fdda630527ee648562cf3e52c5e5f46156a3a971a4ceb443c53a50d8653ef8cf1e5716da68120fb51b636dc6d111ec3277b098ecd42d49d3769d8a1f78b4c17a965f7a30d4181fabbd1f969f46d3c8e83b5ad4845421d8000000e8d4a510002ba4e81542f437b7ae1f8a35ddb233c789a8dc22734377d9b6d63af1ca403b61000000e8d4a51000df8da8c5abfdb38595391308bb71e5a1e0aabdc1d0cf38315d50d6be939b2606000000e8d4a51000b6619edca4143484800281d698b70c935e9152ad57b31d85c05f2f79f64b39f3000000e8d4a510009446d14ad86c8d2d74780b0847110001a1c2e252eedfea4753ebbbfce3a22f52000000e8d4a510000353c639f80cc8015944436dab1032245d44f912edc31ef668ff9f4a45cd0599000000e8d4a51000e81d3797e0544c3a718e1f05f0fb782212e248e784c1a851be87e77ae0db230e000000e8d4a510005e3fcda30bd19d45c4b73688da35e7da1fce7c6859b2c1f20ed5202d24144e3e000000e8d4a51000b06a59a2d75bf5d014fce7c999b5e71e7a960870f725847d4ba3235baeaa08ef000000e8d4a510000c910e2fe650e4e01406b3310b489fb60a84bc3ff5c5bee3a56d5898b6a8af32000000e8d4a5100071f2d7b8ec1c8b99a653429b0118cd201f794f409d0fea4d65b1b662f2b00063000000e8d4a51000");

program.option("--mock <mock>",
    "if use mock",
    false);

program.parse(process.argv);

const data = {
  initConsensusStateBytes: program.initConsensusStateBytes,
  rewardForValidatorSetChange: program.rewardForValidatorSetChange,
  mock: program.mock,
};
const templateString = fs.readFileSync(program.template).toString();
const resultString = nunjucks.renderString(templateString, data);
fs.writeFileSync(program.output, resultString);
console.log("TendermintLightClient file updated.");
