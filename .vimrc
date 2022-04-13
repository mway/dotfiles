if empty(glob('~/.config/nvim/autoload/plug.vim'))
	silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'chriskempson/base16-vim'
Plug 'dense-analysis/ale'
Plug 'edkolev/tmuxline.vim'
Plug 'fatih/vim-go', { 'tag': '*' }
Plug 'folke/lsp-colors.nvim'
Plug 'folke/trouble.nvim'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'neovim/nvim-lspconfig'
Plug 'nvie/vim-flake8'
Plug 'ray-x/lsp_signature.nvim'
Plug 'scrooloose/nerdtree'
Plug 'stephpy/vim-yaml'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

lua << EOF
if vim.env.VIM_PATH then
	vim.env.PATH = vim.env.VIM_PATH
end

local options = {
    autoindent = true,
    autoread = true,
    background = 'dark',
    backspace = {'indent', 'eol', 'start'},
    backup = false,
    cmdheight = 1,
    colorcolumn = '80,100,120',
    compatible = false,
    copyindent = true,
    cursorline = true,
    errorbells = false,
    expandtab = true,
    exrc = true,
    gdefault = true,
    hidden = true,
    history = 700,
    hlsearch = true,
    ignorecase = true,
    incsearch = true,
    joinspaces = false,
    laststatus = 2,
    lazyredraw = true,
    magic = true,
    mat = 2,
    modeline = true,
    mouse = 'a',
    number = true,
    pastetoggle = '<leader>p',
    preserveindent = true,
    ruler = true,
    secure = true,
    shell = '/bin/bash',
    shiftwidth = 4,
    shortmess = 'atI',
    showcmd = true,
    showmatch = true,
    showmode = true,
    smartcase = true,
    softtabstop = 4,
    splitbelow = true,
    splitright = true,
    swapfile = false,
    tabpagemax = 50,
    tabstop = 4,
    textwidth = 79,
    timeoutlen = 300,
    title = true,
    ttimeout = true,
    visualbell = false,
    wrap = false,
    writebackup = false,
    wildignore = {
        '*.o', '*~', '*.pyc',
    },
    wildmenu = true,
}

for name, val in pairs(options) do
	vim.opt[name] = val
end

-- let_g(table)
-- let_g(prefix, table)
--
-- Sets values on g:*. If prefix is non-empty, it's added to every key.
function let_g(prefix, opts)
	if opts == nil then
		opts, prefix = prefix, ''
	end

	for key, val in pairs(opts) do
		if prefix ~= '' then
			key = prefix .. key
		end
		vim.g[key] = val
	end
end

let_g {
	mapleader = ',',
}
EOF

set completeopt-=preview
set formatoptions+=ro

try
  set switchbuf=useopen,usetab,newtab
  set stal=2
catch
endtry

lua << EOF
local nvim_lsp = require('lspconfig')
local lsp_capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lsp_signature = require('lsp_signature')

function setup_lsp(server, lsp_opts)
	lsp_opts.on_attach = function(client, bufnr)
		local function buf_set_keymap(...)
			vim.api.nvim_buf_set_keymap(bufnr, ...)
		end

		local function buf_set_option(...)
			vim.api.nvim_buf_set_option(bufnr, ...)
		end

		-- Show hints for every parameter, but don't need to report the
		-- signature again since it's easily accessible.
		lsp_signature.on_attach({
			bind = true,
			floating_window = false,
			hint_enable = true,
			always_trigger = true,
		}, bufnr)

		buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
		local opts = { noremap = true, silent = true }

		-- Keybindings
		--  K            Documentation
		--  <leader>d    Go to definition
		--  F2           Rename
		--  Alt-Enter    Code action

		buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
		buf_set_keymap('n', '<leader>d', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
		buf_set_keymap('n', '<F1>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
		buf_set_keymap('n', '<M-CR>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	end

	lsp_opts.capabilities = lsp_capabilities
	lsp_opts.flags = {
		-- Don't spam LSP with changes. Wait a second between updates.
		debounce_text_changes = 1000,
	}

	nvim_lsp[server].setup(lsp_opts)
end

-- LSP implementations that don't need any configuration.
local default_lsps = {
	'pylsp',
}

for _, server in pairs(default_lsps) do
	setup_lsp(server, {})
end
EOF

lua << EOF
-- Support disabling gopls and LSP by setting an environment variable,
-- and in diff mode.
local disable_gopls = vim.env.VIM_GOPLS_DISABLED or vim.opt.diff:get()

local gopls_options = {
	gofumpt         = true,
	staticcheck     = true,
	usePlaceholders = true,
}

-- Support overriding memory mode with an environment variable.
if vim.env.VIM_GOPLS_MEMORY_MODE then
	gopls_options.memoryMode = vim.env.VIM_GOPLS_MEMORY_MODE
end

if not disabled_gopls then
	setup_lsp('gopls', {
		cmd = {'gopls', '-remote=auto'},
		init_options = gopls_options,
	})
end
EOF

lua <<EOF
let_g('go_', {
	def_mapping_enabled = 0,
	code_completion_enabled = 0,
	doc_keywordprg_enabled = 0,
	metalinter_autosave_enabled = {},
	gopls_enabled = 0,
	term_enabled = 1,
	term_reuse = 1,
	term_mode = "split",
	template_file = vim.env.HOME .. "/.config/vim-go/main.go",
	template_test_file = vim.env.HOME .. "/.config/vim-go/test.go",
})

if vim.env.VIM_GO_BIN_PATH then
	vim.g.go_bin_path = vim.env.VIM_GO_BIN_PATH
end
EOF

lua << EOF
-- Support disabling gopls and LSP by setting an environment variable,
-- and in diff mode.
local disable_gopls = vim.env.VIM_GOPLS_DISABLED or vim.opt.diff:get()

local gopls_options = {
	gofumpt         = true,
	staticcheck     = true,
	usePlaceholders = true,
}

-- Support overriding memory mode with an environment variable.
if vim.env.VIM_GOPLS_MEMORY_MODE then
	gopls_options.memoryMode = vim.env.VIM_GOPLS_MEMORY_MODE
end

if not disabled_gopls then
	setup_lsp('gopls', {
		cmd = {'gopls', '-remote=auto'},
		init_options = gopls_options,
	})
end
EOF

let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#ale#enabled = 1
let g:airline_theme='base16'
let g:base16colorspace=256
let g:flake8_show_quickfix=1
let g:flake8_show_in_gutter=1
let g:NERDTreeMapOpenInTab = ''
let g:NERDTreeMinimalUI = 1
let g:NERDTreeDirArrows = 1
let g:NERDTreeAutoDeleteBuffer = 1

let g:tmuxline_separators = {
    \ 'left' : '',
    \ 'left_alt': '>',
    \ 'right' : '',
    \ 'right_alt' : '<',
    \ 'space' : ' '}

let g:ale_linters = {
    \ 'go': ['gopls'],
    \ }
let g:ale_lint_on_text_changed = 'never'

colorscheme base16-ocean

""""""
" Keys
nnoremap <leader>q :bp<cr>:bd #<cr>
nnoremap <silent> <expr> <leader>` g:NERDTree.IsOpen() ? "\:NERDTreeClose<CR>" : bufexists(expand('%')) ? "\:NERDTreeFind<CR>" : "\:NERDTree<CR>"
nnoremap <C-J> <C-A-Up>
nnoremap <C-K> <C-A-Down>
nnoremap <C-H> <C-A-Left>
nnoremap <C-L> <C-A-Right>
imap ;; <Esc>
noremap gt :bn<CR>
noremap gT :bp<CR>

highlight TabLine ctermfg=10
highlight LineNr ctermbg=0
highlight colorcolumn ctermbg=0
