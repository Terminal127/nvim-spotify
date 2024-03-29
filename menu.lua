local M = {}
local win_id 
local content 

function M.createPopup()
    local input = vim.fn.input("Enter your query: ")
    local bufnr = vim.api.nvim_create_buf(false, true)

    local handle = io.popen('python3 /mnt/c/Users/KIIT/Desktop/courses/ai/luna/spicefy/neovim-spotify/songnamefinder.py "' .. input .. '"')
    local result = handle:read("*a")
    handle:close()

    -- Convert the JSON string to Lua table
    content = vim.fn.json_decode(result)

    local max_width = 60
    win_id = vim.api.nvim_open_win(bufnr, true, {
        relative = 'editor',
        width = max_width + 2,
        height = #content + 2,
        style = 'minimal',
        border = 'single',
        row = vim.fn.line('.') + 1,
        col = vim.fn.wincol() + 1,
    })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, content)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>lua require('menu').close()<CR>", { silent = true })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", ":lua require('menu').executeOption()<CR>", { silent = true })
end

function M.executeOption()
    local line = vim.fn.line('.')

    local option = content[line]

    if option then
        os.execute("python3 /mnt/c/Users/KIIT/Desktop/courses/ai/luna/spicefy/neovim-spotify/spotify.py " .. vim.fn.shellescape(option))
      else
        print("Invalid option")
    end
end

function M.close()
    if win_id and vim.api.nvim_win_is_valid(win_id) then
        pcall(vim.api.nvim_win_close, win_id, true)
        win_id = nil
    end
end

return M
