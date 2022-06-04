vim.g.rustfmt_autosave = true

setup_lsp('rust_analyzer', {
	settings = {
		['rust-analyzer'] = {
			checkOnSave = {
				command = 'clippy',
			},
		},
	},
})
