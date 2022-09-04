vim.g.flake8_show_quickfix = true
vim.g.flake8_show_in_gutter = true

vim.cmd [[
    autocmd BufWritePre *.py :Black
]]
