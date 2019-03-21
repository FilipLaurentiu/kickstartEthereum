const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
fs.removeSync(buildPath);

const campaignPath = path.resolve(__dirname, 'contracts', 'Campaign.sol');
const source = fs.readFileSync(campaignPath, 'utf-8');

var jsonContractSource = {
    language: 'Solidity',
    sources: {
        'CampaignProj': {
            content: source,
        }
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['*']
            }
        }
    }
}
compiledContract = JSON.parse(solc.compile(JSON.stringify(jsonContractSource)));
const output = compiledContract.contracts.CampaignProj;

fs.ensureDirSync(buildPath);

for (let contract in output) {
    fs.outputJSONSync(path.resolve(buildPath,  contract + '.json'), output[contract]);
}

