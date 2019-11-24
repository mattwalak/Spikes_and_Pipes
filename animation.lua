local CN = require("crazy_numbers")

--Coin sprite things
local sheetOptions_coin =
{
	width = 100,
	height = 100,
	numFrames = 8
}

local sheet_coin = graphics.newImageSheet("Game/Item/coin.png", sheetOptions_coin)
local sequences_coin = {
	{
		name = "normal",
		start = 1,
		count = 8,
		time = 800,
		loopCount = 0,
		loopDirection = "forward"
	}
}


local animation = {
	sheet_coin = sheet_coin,
	sequences_coin = sequences_coin,
}

return animation