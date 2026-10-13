-- Matrix OS: green phosphor neovim, no plugins needed
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.undofile = true
vim.g.mapleader = " "

vim.cmd("highlight clear")
vim.g.colors_name = "matrix"
local c = { bg = "NONE", dim = "#1f8f45", fg = "#3dff74", hi = "#b6ffcf", bright = "#d9ffe6",
            mute = "#2f6b45", line = "#07140b", sel = "#0f3a1f", red = "#ff3d3d", yellow = "#d7ff3d" }
local hl = function(group, opts) vim.api.nvim_set_hl(0, group, opts) end
hl("Normal", { fg = c.fg, bg = c.bg })
hl("NormalFloat", { fg = c.fg, bg = c.line })
hl("FloatBorder", { fg = c.dim, bg = c.line })
hl("CursorLine", { bg = c.line })
hl("CursorLineNr", { fg = c.bright, bold = true })
hl("LineNr", { fg = c.mute })
hl("Visual", { bg = c.sel })
hl("Search", { fg = "#020a05", bg = c.fg })
hl("IncSearch", { fg = "#020a05", bg = c.bright })
hl("StatusLine", { fg = "#020a05", bg = c.fg, bold = true })
hl("StatusLineNC", { fg = c.fg, bg = c.line })
hl("VertSplit", { fg = c.dim })
hl("WinSeparator", { fg = c.dim })
hl("Pmenu", { fg = c.fg, bg = c.line })
hl("PmenuSel", { fg = "#020a05", bg = c.fg })
hl("Comment", { fg = c.mute, italic = true })
hl("String", { fg = c.hi })
hl("Constant", { fg = c.bright })
hl("Number", { fg = c.bright })
hl("Identifier", { fg = c.fg })
hl("Function", { fg = c.bright, bold = true })
hl("Statement", { fg = c.hi, bold = true })
hl("Keyword", { fg = c.hi, bold = true })
hl("Type", { fg = "#8fdc5a" })
hl("PreProc", { fg = "#4fe0a5" })
hl("Special", { fg = "#74ffc4" })
hl("Error", { fg = c.red, bold = true })
hl("ErrorMsg", { fg = c.red, bold = true })
hl("WarningMsg", { fg = c.yellow })
hl("Todo", { fg = "#020a05", bg = c.yellow, bold = true })
hl("MatchParen", { fg = c.bright, bg = c.sel, bold = true })
hl("NonText", { fg = c.mute })
hl("DiagnosticError", { fg = c.red })
hl("DiagnosticWarn", { fg = c.yellow })
hl("DiagnosticInfo", { fg = c.hi })
hl("DiagnosticHint", { fg = c.dim })
