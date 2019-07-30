if exists('s:initialized')
  finish
endif
let s:initialized = v:true

function! s:FindCommand() abort
  let l:dart = resolve(exepath('dart'))
  if len(l:dart) == 0
    echoerr 'Could not find an executable `dart`'
    return v:null
  endif
  let l:bin = fnamemodify(l:dart, ':h')
  let l:snapshot = l:bin.'/snapshots/analysis_server.dart.snapshot'
  if !filereadable(l:snapshot)
    echoerr 'Could not find analysis server snapshot at '.l:snapshot
    return v:null
  endif
  let l:cmd = ['dart', l:snapshot, '--lsp']
  let l:sdk_root = fnamemodify(l:bin, ':h')
  let l:language_model = l:sdk_root.'/model/lexeme'
  if isdirectory(l:language_model)
    call add(l:cmd, '--completion-model='.l:language_model)
  endif
  return l:cmd
endfunction

function! s:RegisterDartServer() abort
  let l:command = s:FindCommand()
  if type(l:command) == type(v:null) | return | endif
  let l:config = {
      \ 'name': 'Dart Analysis Server',
      \ 'command': l:command,
      \ 'message_hooks': {
      \   'initialize': {
      \     'initializationOptions': {
      \       'onlyAnalyzeProjectsWithOpenFiles': v:true
      \     }
      \   },
      \   'textDocument/documentHighlight': function('<SID>SkipYamlRequests'),
      \   'textDocument/completion': function('<SID>SkipYamlRequests'),
      \ },
      \ 'notifications': {
      \   '$/analyzerStatus': function('<SID>HandleStatus'),
      \ },
      \}
  call RegisterLanguageServer('dart', l:config)
  call RegisterLanguageServer('yaml', 'Dart Analysis Server')
endfunction

function! s:SkipYamlRequests(method, params) abort
  return a:params.textDocument.uri =~? '\v\.yaml$' ?
      \ lsc#config#skip() : a:params
endfunction

function! s:HandleStatus(method, params) abort
  let g:dart_analyzer_status = a:params.isAnalyzing
endfunction

call s:RegisterDartServer()
