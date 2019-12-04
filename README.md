Registers the Dart Analysis Server as a language server with
[`vim-lsc`](https://github.com/natebosch/vim-lsc)

# Commands

`:DartAnalysisServerDiagnostics`. Request that the analyzer starts a diagnostic
server and report the port is is using on localhost. Visit the reported URL in a
browser to see information about the running analysis server.

`:DartToggleMethodBodyType`. With the cursor on either a `return` statement
(when it is the only statement in a method block) or on the `=>` in a method
definition, toggle between the two ways to write the method. If it is an
expression body method (`=>`) convert to a block body (`{}` and a `return`) or
vice versa. Recommended mapping (in `ftplugin/dart.vim`):

```viml
noremap <buffer> <leader>tr :DartToggleMethodBodyType<cr>
```
