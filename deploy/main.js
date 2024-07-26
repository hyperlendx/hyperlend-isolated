const Core = require("./HyperlendCore")
const Market = require("./HyperlendMarket")

main()

async function main(){
    await Core.main()
    await Market.main()
}