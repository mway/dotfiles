local gopls_flags = '-remote=auto'
local gopls_options = {
	gofumpt     = true,
	staticcheck = true,
	analyses = {
        unusedparams = true,
        unreachable  = true,
	},
}

vim.g.go_fmt_command = 'gopls'
vim.g.go_imports_mode = 'gopls'
vim.g.go_metalinter_command = 'gopls'

vim.g.go_gopls_gofumpt = true
vim.g.go_gopls_options = {gopls_flags}

vim.g.ale_go_gopls_options = gopls_flags
vim.g.ale_go_gopls_init_options = gopls_options
vim.g.ale_go_gopls_use_global = true

if vim.env.VIM_GOPLS_MEMORY_MODE then
	gopls_options.memoryMode = vim.env.VIM_GOPLS_MEMORY_MODE
end

local disable_gopls = vim.env.VIM_GOPLS_DISABLED or vim.opt.diff:get()
if not disabled_gopls then
	setup_lsp('gopls', {
		cmd = {'gopls', gopls_flags},
		init_options = gopls_options,
	})
end
