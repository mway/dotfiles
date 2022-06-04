vim.g.UltiSnips = {
	ExpandTrigger            = "<Plug>(ultisnips_expand)",
	JumpForwardTrigger       = "<Plug>(ultisnips_jump_forward)",
	JumpBackwardTrigger      = "<Plug>(ultisnips_jump_backward)",
	ListSnippets             = "<c-x><c-s>",
	RemoveSelectModeMappings = 0,
}

vim.keymap.set('i', '<c-u>', '<Plug>(ultisnips_expand)')
