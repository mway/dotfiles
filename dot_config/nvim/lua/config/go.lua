vim.g.go_fmt_autosave = true
vim.g.go_imports_autosave = true
vim.g.go_def_mapping_enabled = false
vim.g.go_code_completion_enabled = false
vim.g.go_doc_keywordprg_enabled = false
vim.g.go_metalinter_autosave_enabled = {}
vim.g.go_gopls_enabled = true
vim.g.go_gopls_gofumpt = true
vim.g.go_term_enabled = true
vim.g.go_term_reuse = true
vim.g.go_term_mode = "split"

if vim.env.VIM_GO_BIN_PATH then
    vim.g.go_bin_path = vim.env.VIM_GO_BIN_PATH
end

vim.cmd [[
    autocmd FileType go nnoremap <buffer> ga :GoAlternate<CR>
    autocmd FileType go nnoremap <buffer> gb :GoBuild<CR>
    autocmd FileType go nnoremap <buffer> gf :GoFillStruct<CR>
    autocmd FileType go nnoremap <buffer> gl :GoLint<CR>
]]

--[[
local goFormatAndImports = function(wait_ms)
    vim.lsp.buf.format({
        timeout_ms = wait_ms,
    })
    -- vim.lsp.buf.formatting_sync(nil, wait_ms)

    local params = vim.lsp.util.make_range_params()
    params.context = {only = {"source.organizeImports"}}

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
    for _, res in pairs(result or {}) do
        for _, r in pairs(res.result or {}) do
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
        goFormatAndImports(10000)
    end,
})
]]--
