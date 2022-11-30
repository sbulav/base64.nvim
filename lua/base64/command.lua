local module = {}

local encoding = require("base64.encoding")

function module.encode()
	module.process_selection(true)
end

function module.decode()
	module.process_selection(false)
end

local function is_valid(c)
	return c == "=" or encoding.base64bytes[c] ~= nil
end

function module.process_selection(encode_mode)
	local content = ""
	local mode = vim.api.nvim_get_mode().mode
	if mode == "n" then
		local cursor = vim.api.nvim_win_get_cursor(0)
		local row, col = cursor[1], cursor[2]

		local line = vim.api.nvim_get_current_line()
		local right_num = 0
		for i = col + 1, #line do
			local c = line:sub(i, i)
			if is_valid(c) then
				right_num = right_num + 1
				content = content .. c
			else
				break
			end
		end
		local left_num = 0
		for i = col, 1, -1 do
			local c = line:sub(i, i)
			if is_valid(c) then
				left_num = left_num + 1
				content = c .. content
			else
				break
			end
		end
		local ret = ""
		if encode_mode then
			ret = encoding.enc(content)
		else
			ret = encoding.dec(content)
		end
		if select(2, ret:gsub("\n", "\n")) > 0 then
			print("Multiline detected, use Visual mode for this")
		else
			vim.api.nvim_buf_set_text(0, row - 1, col - left_num, row - 1, col + right_num, { ret })
		end
	else
		-- save paste mode
		local paste = vim.opt.paste
		-- turn paste on
		vim.opt.paste = true
		-- use b register as cache
		local reg = "b"
		-- cache old reg contents
		local buf_cache = vim.fn.getreg(reg)

		-- grab previously selected text into reg
		vim.cmd('normal! gv"' .. reg .. "x")
		content = vim.fn.getreg(reg)
		local ret = ""
		if encode_mode then
			ret = encoding.enc(content)
		else
			ret = encoding.dec(content)
		end
		vim.api.nvim_paste(ret, true, -1)
		-- restore buffer contents
		vim.fn.setreg(reg, buf_cache)
		-- reset paste mode
		vim.opt.paste = paste
	end
end

return module
