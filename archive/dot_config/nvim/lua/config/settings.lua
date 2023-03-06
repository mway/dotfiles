if vim.env.VIM_PATH then
	vim.env.PATH = vim.env.VIM_PATH
end

local options = {
    autoindent = true,
    autoread = true,
    background = 'dark',
    backspace = {'indent', 'eol', 'start'},
    backup = false,
    cmdheight = 2,
    colorcolumn = '80,100,120',
    compatible = false,
    copyindent = true,
    cursorline = true,
    errorbells = false,
    expandtab = true,
    exrc = true,
    gdefault = true,
    hidden = true,
    history = 100,
    hlsearch = true,
    ignorecase = true,
    incsearch = true,
    joinspaces = false,
    laststatus = 2,
    lazyredraw = true,
    magic = true,
    mat = 2,
    modeline = true,
    mouse = '',
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
    signcolumn = 'no',
    smartcase = true,
    softtabstop = 4,
    splitbelow = true,
    splitright = true,
    showtabline = 2,
    swapfile = false,
    switchbuf = {'useopen', 'usetab', 'newtab'},
    tabpagemax = 50,
    tabstop = 4,
    textwidth = 0,
    timeoutlen = 300,
    title = true,
    ttimeout = true,
    visualbell = false,
    wildignore = {'*.o', '*~', '*.pyc'},
    wildmenu = true,
    wrap = false,
    writebackup = false,
}

for name, val in pairs(options) do
	vim.opt[name] = val
end

vim.opt.completeopt:remove('preview')
vim.opt.formatoptions:append('ro')
