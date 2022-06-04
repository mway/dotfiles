vim.g.go_gopls_gofumpt = true

local gopls_options = {
	gofumpt     = true,
	staticcheck = true,
	analyses = {
        unusedparams = true,
        unreachable  = true,
	},
}

if vim.env.VIM_GOPLS_MEMORY_MODE then
	gopls_options.memoryMode = vim.env.VIM_GOPLS_MEMORY_MODE
end

local disable_gopls = vim.env.VIM_GOPLS_DISABLED or vim.opt.diff:get()
if not disabled_gopls then
	setup_lsp('gopls', {
		cmd = {'gopls', '-remote=auto'},
		init_options = gopls_options,
	})
end

