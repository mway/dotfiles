vim.g.NERDTreeMapOpenInTab = ''
vim.g.NERDTreeMinimalUI = true
vim.g.NERDTreeDirArrows = true
vim.g.NERDTreeAutoDeleteBuffer = true

vim.cmd [[
    nnoremap <silent> <expr> <leader>` g:NERDTree.IsOpen() ? "\:NERDTreeClose<CR>" : bufexists(expand('%')) ? "\:NERDTreeFind<CR>" : "\:NERDTree<CR>"
]]
