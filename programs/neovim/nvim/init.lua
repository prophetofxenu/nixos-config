vim.g.mapleader = " "

require('bufferline').setup {}

require('omni').colorscheme()

require('guess-indent').setup {}

require('lualine').setup {
  options = {
    theme = 'omni'
  }
}

require('telescope').setup {
  extensions = {
    file_browser = {
      --theme = "omni",
      hijack_netrw = true,
    }
  }
}
require('telescope').load_extension "file_browser"
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>do', vim.diagnostic.open_float, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fd', builtin.diagnostics, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>ef', function()
  require('telescope').extensions.file_browser.file_browser()
end)

require('toggleterm').setup {
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = [[<c-j>]]
}

-- LSP
vim.lsp.config('zls', {
  cmd = { 'zls' },
  filetypes = { 'zig' },
})
vim.lsp.enable('zls')

-- settings
vim.cmd[[set number]]

