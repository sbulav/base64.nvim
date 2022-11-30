-- https://github.com/taybart/b64.nvim/blob/main/lua/b64.lua
--
local encoding = {}
-- http://lua-users.org/wiki/BaseSixtyFour
local dic = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

-- decryption table
encoding.base64bytes = {
	["A"] = 0,
	["B"] = 1,
	["C"] = 2,
	["D"] = 3,
	["E"] = 4,
	["F"] = 5,
	["G"] = 6,
	["H"] = 7,
	["I"] = 8,
	["J"] = 9,
	["K"] = 10,
	["L"] = 11,
	["M"] = 12,
	["N"] = 13,
	["O"] = 14,
	["P"] = 15,
	["Q"] = 16,
	["R"] = 17,
	["S"] = 18,
	["T"] = 19,
	["U"] = 20,
	["V"] = 21,
	["W"] = 22,
	["X"] = 23,
	["Y"] = 24,
	["Z"] = 25,
	["a"] = 26,
	["b"] = 27,
	["c"] = 28,
	["d"] = 29,
	["e"] = 30,
	["f"] = 31,
	["g"] = 32,
	["h"] = 33,
	["i"] = 34,
	["j"] = 35,
	["k"] = 36,
	["l"] = 37,
	["m"] = 38,
	["n"] = 39,
	["o"] = 40,
	["p"] = 41,
	["q"] = 42,
	["r"] = 43,
	["s"] = 44,
	["t"] = 45,
	["u"] = 46,
	["v"] = 47,
	["w"] = 48,
	["x"] = 49,
	["y"] = 50,
	["z"] = 51,
	["0"] = 52,
	["1"] = 53,
	["2"] = 54,
	["3"] = 55,
	["4"] = 56,
	["5"] = 57,
	["6"] = 58,
	["7"] = 59,
	["8"] = 60,
	["9"] = 61,
	["-"] = 62,
	["_"] = 63,
	["="] = nil,
}
-- encoding
function encoding.enc(data)
	return (
		(data:gsub(".", function(x)
			local r, b = "", x:byte()
			for i = 8, 1, -1 do
				r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
			end
			return r
		end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
			if #x < 6 then
				return ""
			end
			local c = 0
			for i = 1, 6 do
				c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
			end
			return dic:sub(c + 1, c + 1)
		end) .. ({ "", "==", "=" })[#data % 3 + 1]
	)
end

-- decoding
function encoding.dec(data)
	data = string.gsub(data, "[^" .. dic .. "=]", "")
	return (
		data:gsub(".", function(x)
			if x == "=" then
				return ""
			end
			local r, f = "", (dic:find(x) - 1)
			for i = 6, 1, -1 do
				r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
			end
			return r
		end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
			if #x ~= 8 then
				return ""
			end
			local c = 0
			for i = 1, 8 do
				c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
			end
			return string.char(c)
		end)
	)
end

return encoding
