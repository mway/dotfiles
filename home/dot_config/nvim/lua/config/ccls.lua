local ccls_options = {
    index = {
        threads = 0,
    },
	highlight = {
        lsRanges = true,
	},
	cache = {
        directory = vim.fn.stdpath('cache') .. '/ccls',
	},
}

local disable_ccls = vim.env.VIM_CCLS_DISABLED or vim.opt.diff:get()
if not disabled_ccls then
	setup_lsp('ccls', {
		cmd = {'ccls'},
		init_options = ccls_options,
		filetypes = {'c', 'cpp', 'cc', 'h', 'hh'},
	})
end
