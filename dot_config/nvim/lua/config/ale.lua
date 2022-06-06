vim.g.ale_lint_on_enter          = false
vim.g.ale_lint_on_save           = true
vim.g.ale_lint_on_text_changed   = false
vim.g.ale_linters                = {
    go = {'gopls'},
    rust = {},
}
-- vim.g.ale_open_list              = true
vim.g.ale_set_signs              = true
vim.g.ale_sign_error             = '>>'
vim.g.ale_sign_warning           = '--'
