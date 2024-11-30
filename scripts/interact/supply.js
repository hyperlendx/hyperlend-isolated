main()

async function main(){
    const [deployer] = await hre.ethers.getSigners();

    const pair = await ethers.getContractAt("HyperlendPair", "0xB1ed098b6b7Ae18b0Aa822c90a1E0371c7fDb96D")
    const weth = await ethers.getContractAt("@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20", "0xe0bdd7e8b7bf5b15dcDA6103FCbBA82a460ae2C7")
    const sttesth = await ethers.getContractAt("@openzeppelin/contracts/token/ERC20/IERC20.sol:IERC20", "0x4D6b8f9518b0b92080b5eAAf80bD505734A059Ae")
    const sttesthoverseer = await ethers.getContractAt("IStTESTHOverseer", "0xD53902aDB00ae787fD7d63c97F6213327c0fC38A")

    await weth.approve(pair.target, ethers.parseEther("1"))
    await pair.addCollateral(ethers.parseEther("1"), deployer.address)
    console.log(`collateral added`)

    await sttesthoverseer.mint(deployer.address, { value: ethers.parseEther("1") })
    console.log(`sttesth minted`)

    await sttesth.approve(pair.target, ethers.parseEther("1"))
    await pair.deposit(ethers.parseEther("1"), deployer.address)
    console.log(`asset deposited`)

    await pair.borrowAsset(ethers.parseEther("0.5"), 0, deployer.address)
    console.log(`borrowed`)
}