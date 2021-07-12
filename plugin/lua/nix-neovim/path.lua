local M = {}

-- Vim variables:
-- g:nix_neovim_path: Contains the required dependencies
-- g:nix_neovim_current_style: Currently active style

M.normal_path = vim.env.PATH

M.switch = function(style)
    if vim.g.nix_neovim_path == "nopath" then
        print("nix-neovim: `nopath` style configured, live switching to other styles is impossible")
    elseif style == "pure" then
        vim.env.PATH = vim.g.nix_neovim_path
	vim.g.nix_neovim_current_style = style
    elseif style == "impure" then
        vim.env.PATH = vim.g.nix_neovim_path .. ":" .. M.normal_path
	vim.g.nix_neovim_current_style = style
    elseif style == "nopath" then
        vim.env.PATH = M.normal_path
	vim.g.nix_neovim_current_style = style
    elseif type(style) == "string" then
        print("nix-neovim: trying to switch to invalid path style: " .. style)
    else
        print("nix-neovim: invalid type for style: " .. type(style))
    end
end

M.health_check = function()
    vim.fn['health#report_start']("Purity")
    vim.fn['health#report_ok']('Purity level: `' .. vim.g.nix_neovim_current_style .. '`')

    if vim.g.nix_neovim_path == "nopath" then
        vim.fn['health#report_warn']('`nopath` style configured, live switching to other styles is impossible (output.path.style = "nopath")', {"Recompile your configuration with a different `output.path.style`."})
    end

    vim.fn['health#report_info']("$PATH = " .. vim.env.PATH)
end

return M
