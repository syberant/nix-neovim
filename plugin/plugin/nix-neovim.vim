if exists('g:loaded_nix_neovim') | finish | endif

lua require('nix-neovim-path').switch(vim.g.nix_neovim_current_style)

" TODO: Consolidate these into one command passing the arguments to the
" `switch` function.
command NixNeovimPathPure lua require('nix-neovim-path').switch('pure')
command NixNeovimPathImpure lua require('nix-neovim-path').switch('impure')
command NixNeovimPathNopath lua require('nix-neovim-path').switch('nopath')

let g:loaded_nix_neovim = 1
