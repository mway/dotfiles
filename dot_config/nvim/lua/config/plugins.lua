local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'SirVer/ultisnips'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'chriskempson/base16-vim'
Plug 'dense-analysis/ale'
Plug 'direnv/direnv.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'fatih/vim-go'
Plug 'folke/lsp-colors.nvim'
Plug 'folke/trouble.nvim'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp'
-- Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'hynek/vim-python-pep8-indent'
Plug 'neovim/nvim-lspconfig'
Plug 'nvie/vim-flake8'
Plug 'psf/black'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'
Plug 'ray-x/lsp_signature.nvim'
Plug 'rhysd/vim-clang-format'
Plug 'rhysd/vim-lsp-ale'
Plug 'rust-lang/rust.vim'
Plug 'scrooloose/nerdtree'
Plug 'stephpy/vim-yaml'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug('dracula/vim', { as = 'dracula' })

vim.call('plug#end')
