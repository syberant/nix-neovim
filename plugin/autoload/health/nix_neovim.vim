" See :help pi_health.txt for documentation about health#* functions

" nix_neovim instead of nix-neovim here because neovim otherwise throws a hissy fit
" with E107: Missing parentheses
function! health#nix_neovim#check() abort
lua << EOF
    vim.fn['health#report_start']('General')
    vim.fn['health#report_ok']('Neovim configuration was generated by nix-neovim')
    vim.fn['health#report_info']('See :help nix-neovim-configuration.txt for available options')
    vim.fn['health#report_info']('Run :NixNeovimRc to inspect the generated configuration')
    vim.fn['health#report_info']('Run :NixNeovimPlugins to inspect the installed plugins')

    require('nix-neovim.path').health_check()
EOF
endfunction
