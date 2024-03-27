local M = {}
local win_id -- Declare win_id outside of the function so it's accessible to other functions
local content -- Variable to store the content displayed in the popup

function M.createPopup()
    -- Prompt the user for input
    local input = vim.fn.input("Enter your query: ")

    -- Create a buffer for the popup content
    local bufnr = vim.api.nvim_create_buf(false, true)

    -- Call the Python script to fetch song names and artist names
    local handle = io.popen('python3 /mnt/c/Users/KIIT/Desktop/courses/ai/luna/spicefy/neovim-spotify/songnamefinder.py "' .. input .. '"')
    local result = handle:read("*a")
    handle:close()

    -- Convert the JSON string to Lua table
    content = vim.fn.json_decode(result)

    -- Create and open a window for the popup
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

    -- Set the buffer content
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, content)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>lua require('menu').close()<CR>", { silent = true })
    -- Set up key mappings for selecting options
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<CR>", ":lua require('menu').executeOption()<CR>", { silent = true })
end

function M.executeOption()
    -- Get the line number of the cursor in the buffer
    local line = vim.fn.line('.')

    -- Retrieve the selected option based on the line number
    local option = content[line]

    if option then
        -- Execute Python code with selected option name
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
