vim.g.mapleader = ','

vim.keymap.set('n', '<leader>q', ':bp<cr>:bd> #<cr>')
vim.keymap.set('n', '<C-J>', '<C-A-Up>')
vim.keymap.set('n', '<C-K>', '<C-A-Down>')
vim.keymap.set('n', '<C-H>', '<C-A-Left>')
vim.keymap.set('n', '<C-L>', '<C-A-Right>')
vim.keymap.set('n', 'gt', ':bn<CR>')
vim.keymap.set('n', 'gT', ':bp<CR>')
vim.keymap.set('i', ';;', '<Esc>')
