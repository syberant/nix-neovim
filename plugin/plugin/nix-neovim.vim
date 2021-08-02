if exists('g:loaded_nix_neovim') | finish | endif

lua require('nix-neovim.path').switch(vim.g.nix_neovim_current_style)

" TODO: Consolidate these into one command passing the arguments to the
" `switch` function.
command NixNeovimPathPure lua require('nix-neovim.path').switch('pure')
command NixNeovimPathImpure lua require('nix-neovim.path').switch('impure')
command NixNeovimPathNopath lua require('nix-neovim.path').switch('nopath')

" Open plugins directory, allows you to explore their source code
command NixNeovimPlugins lua vim.cmd("edit " .. vim.opt.runtimepath:get()[1] .. "/pack/myVimPackage")

let g:loaded_nix_neovim = 1
