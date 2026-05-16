vim.g.mapleader = " "

require('omni').colorscheme()

require('guess-indent').setup {}

require('lualine').setup {}

require('telescope').setup {}
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

require('toggleterm').setup {
  open_mapping = [[<c-j>]]
}

vim.cmd[[set number]]
