# Neovim README

## General keymap
  * `<leader>` is `\` (backslash)
  * `<leader>qq` to close current pane
  * `<leader>qa` to quit vim
  * `<leader>m` to toggle mouse support (useful to allow select + copy)

## Buffers
  * `<leader> 1 through 9` to switch between opened buffers
  * `<leader>]` to switch to next buffer
  * `<leader>[` to switch to previous buffer
  * `<leader>s` to save current buffer
  * `<leader>x` to save and then execute current buffer (as long as it's chmod +x)
  * `<leader>z` to execute current visual selection in a shell
  * `<leader>w` to close the current buffer by trying not to messup the layout
  * `<leader>o` to close all buffers except the current one

## Fzf
  * `<leader>ff` fuzzy finding file names
  * `<leader>fs` fuzzy find in current file
  * `<leader>fS` fuzzy find in workspace / file contents
  * When open, `<ctrl>q`, sends matches to the quickfix list
  * See [plgin.fzf.vim](./home-manager/modules/neovim/plugins/fzf.vim) for more

## Editing & navigation
  * `<leader>y` to yank to clipboard using [bin/pbcopy](bin/pbcopy) util
  * `<leader>p` to paste from clipboard using [bin/pbpaste](bin/pbpaste) util
  * `<ctrl>o` go back to previous cursor
  * `<ctrl>i` go forward to next cursor
  * `<leader>cc` comment
  * `<leader>cu` uncomment

## Code / LSP
  * `gD` goto declaration
  * `gd` goto definition
  * `gi` goto implementation
  * `K` hover info
  * `<space>rn` rename symbol

## Nvim tree
  * `<ctrl>e` to toggle filetree
  * In tree
    * `g?` to show help
    * `<ctrl>]` to CD into directory
    * `-` go up one directory
    * `<ctrl>v` Open in vertical split
    * `<ctrl>x` Open in horizontal split
    * `I` Toggle hidden files
    * `r` Rename file
    * `d` Delete file
    * `a` Add file or directory if it ends with `/`
    * `c`, `x`, `v` to copy, cut, paste files
    * `f` to find file, `F` to clear
    * `q` to close tree
    * `E` to expand all, `W` to collapse

## Git
  * `:Git` or `:G` or `<leader>fgs` git status
  * `<leader>fgb` git branches
  * `:Gdiff` to see diff
  * `:Gwrite` stages current file
  * `:Gcommit` to commit
  * `:Glog` to show log
  * `:Gblame` to show blame

## Quickfix
* `<leader>qo` to open quickfix
* `<leader>qc` to close quickfix
* `<leader>qn` to go to next quickfix
* `<leader>qp` to go to prev quickfix

## Commands
  * `Rename <file name>` to rename current file
  * `Edit <file name>` to create a file in current buffer dir
  * `Delete` to delete current file