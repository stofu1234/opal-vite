" opal-vite.vim - Vim/Neovim plugin for Opal development with Vite
" Maintainer: stofu1234
" Version: 0.3.8

if exists('g:loaded_opal_vite')
  finish
endif
let g:loaded_opal_vite = 1

" Configuration options
if !exists('g:opal_vite_enable_diagnostics')
  let g:opal_vite_enable_diagnostics = 1
endif

if !exists('g:opal_vite_diagnostic_severity')
  let g:opal_vite_diagnostic_severity = 'warn'
endif

if !exists('g:opal_vite_auto_detect')
  let g:opal_vite_auto_detect = 1
endif

" Auto-detect Opal files
augroup OpalViteDetect
  autocmd!
  autocmd BufRead,BufNewFile */app/opal/**/*.rb setlocal filetype=ruby | let b:opal_file = 1
  autocmd BufRead,BufNewFile */opal/**/*.rb setlocal filetype=ruby | let b:opal_file = 1
augroup END

" Commands
command! OpalInfo call s:ShowInfo()
command! OpalToggleDiagnostics call s:ToggleDiagnostics()

function! s:ShowInfo()
  if has('nvim')
    lua require('opal_vite').show_info()
  else
    echo 'Opal-Vite plugin loaded. For LSP support, use Neovim with nvim-lspconfig.'
  endif
endfunction

function! s:ToggleDiagnostics()
  if has('nvim')
    lua require('opal_vite').toggle_diagnostics()
  else
    let g:opal_vite_enable_diagnostics = !g:opal_vite_enable_diagnostics
    echo 'Opal diagnostics: ' . (g:opal_vite_enable_diagnostics ? 'Enabled' : 'Disabled')
  endif
endfunction

" Initialize Neovim Lua module automatically
if has('nvim')
  lua << EOF
  -- Defer loading to allow user configuration
  vim.defer_fn(function()
    -- Only auto-setup if user hasn't called setup manually
    if not vim.g.opal_vite_no_auto_setup then
      local ok, opal_vite = pcall(require, 'opal_vite')
      if ok and not opal_vite._setup_called then
        -- Check if lspconfig is available before auto-setup
        local lsp_ok = pcall(require, 'lspconfig')
        if lsp_ok then
          opal_vite.setup({})
        end
      end
    end
  end, 100)
EOF
endif
