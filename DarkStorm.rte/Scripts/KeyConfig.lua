function InitializeKeys()
	--only bother doing anything if something isn't set
	if PlayerOneDarkStormSecondaryFire == nil or PlayerTwoDarkStormSecondaryFire == nil or PlayerThreeDarkStormSecondaryFire == nil or PlayerFourDarkStormSecondaryFire == nil or 
	PlayerOneDarkStormMelee == nil or PlayerTwoDarkStormMelee == nil or PlayerThreeDarkStormMelee == nil or PlayerFourDarkStormMelee == nil then
		--set up I/O
		local io = require("io");
		io.input("DarkStorm.rte/keyconfig.ini");
		
		--read lines
		for line in io.lines() do
			--find a number on the line. should only be one, but stop at the first one
			local keyNum = nil;
			for number in string.gmatch(line, "%d+") do
				keyNum = tonumber(number);
				break;
			end
			
			if keyNum ~= nil then
				--find which key the line references, and set the key number
				if string.find(line, "PlayerOneDarkStormSecondaryFire") ~= nil then
					PlayerOneDarkStormSecondaryFire = keyNum;
				elseif string.find(line, "PlayerTwoDarkStormSecondaryFire") ~= nil then
					PlayerTwoDarkStormSecondaryFire = keyNum;
				elseif string.find(line, "PlayerThreeDarkStormSecondaryFire") ~= nil then
					PlayerThreeDarkStormSecondaryFire = keyNum;
				elseif string.find(line, "PlayerFourDarkStormSecondaryFire") ~= nil then
					PlayerFourDarkStormSecondaryFire = keyNum;
				elseif string.find(line, "PlayerOneDarkStormMelee") ~= nil then
					PlayerOneDarkStormMelee = keyNum;
				elseif string.find(line, "PlayerTwoDarkStormMelee") ~= nil then
					PlayerTwoDarkStormMelee = keyNum;
				elseif string.find(line, "PlayerThreeDarkStormMelee") ~= nil then
					PlayerThreeDarkStormMelee = keyNum;
				elseif string.find(line, "PlayerFourDarkStormMelee") ~= nil then
					PlayerFourDarkStormMelee = keyNum;
				end
			end
		end
	end
end