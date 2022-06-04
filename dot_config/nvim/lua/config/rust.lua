vim.g.rustfmt_autosave = true
-- vim.g.ale_linters.rust = {}

setup_lsp('rust_analyzer', {
	settings = {
		['rust-analyzer'] = {
			checkOnSave = {
				command = 'clippy',
			},
		},
	},
})
