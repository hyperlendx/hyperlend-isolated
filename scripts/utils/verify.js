const fs = require("fs");
const path = require("path")

async function verify(address, args, libraries, { verificationDataDir, verificationDataPath }, showLogs = false){
    const params = {
        address: address,
        constructorArguments: args,
    }

    if (libraries){
        params.libraries = libraries
    }

    try {
        if (showLogs) console.log(`verifying ${address} with args: ${args}`);
        await storeVerification(address, args, libraries, { verificationDataDir, verificationDataPath })
        await hre.run("verify:verify", params);
    } catch (e) {
        if (showLogs) {
            console.log(`verification failed`);
            console.log(e);
        }
    }
}

async function storeVerification(address, args, libraries, { verificationDataDir, verificationDataPath }){
    const params = {
        address: address,
        constructorArguments: args,
    }

    if (libraries){
        params.libraries = libraries
    }

    if (!verificationDataDir) verificationDataDir = path.resolve(__dirname, `./verifications/`)
    if (!verificationDataPath) verificationDataPath = path.resolve(__dirname, `./verifications/${address}.json`)

    await storeVerificationData(
        verificationDataDir,
        verificationDataPath,
        JSON.stringify(params, null, 4)
    );
}

async function storeVerificationData(dir, filePath, data){
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(filePath, data);
}

module.exports = {
    verify: verify,
    storeVerification: storeVerification
};