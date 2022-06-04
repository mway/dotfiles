vim.g.go_fmt_command = 'gopls'
vim.g.go_imports_autosave = true
vim.g.go_imports_mode = 'gopls'
vim.g.go_metalinter_command = 'gopls'

local goFormatAndImports = function(wait_ms)
    print("goFormatAndImports")

	vim.lsp.buf.format({
	    timeout_ms = wait_ms,
    })

	local params = vim.lsp.util.make_range_params()
	params.context = {only = {"source.organizeImports"}}

	local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
	for _, res in pairs(result or {}) do
		for _, r in pairs(res.result or {}) do
            print(r.edit, "<-->", r.command)
			if r.edit then
				vim.lsp.util.apply_workspace_edit(r.edit, "UTF-8")
			else
				vim.lsp.buf.execute_command(r.command)
			end
		end
	end
end

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.go",
	callback = function(args)
		goFormatAndImports(100000) --3000)
	end,
})
