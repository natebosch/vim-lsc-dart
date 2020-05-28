function! lsc#dart#register() abort
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
  call RegisterLanguageServer('html', 'Dart Analysis Server')
endfunction

function! s:FindCommand() abort
  let l:dart = s:FindDart()
  if type(l:dart) != type('') | return v:null | endif
  let l:bin = fnamemodify(l:dart, ':h')
  let l:snapshot = l:bin.'/snapshots/analysis_server.dart.snapshot'
  if !filereadable(l:snapshot)
    echoerr 'Could not find analysis server snapshot at '.l:snapshot
    return v:null
  endif
  let l:cmd = [l:dart, l:snapshot, '--lsp', '--client-id', 'vim']
  let l:sdk_root = fnamemodify(l:bin, ':h')
  let l:language_model = l:sdk_root.'/model/lexeme'
  if isdirectory(l:language_model)
    call add(l:cmd, '--completion-model='.l:language_model)
  endif
  if get(g:, 'lsc_dart_enable_log', v:false)
    let l:log_file = tempname()
    call add(l:cmd, '--instrumentation-log-file='.l:log_file)
    echom 'Dart instrumentation log: '.l:log_file
  endif
  return l:cmd
endfunction

function! s:FindDart() abort
  if executable('dart') | return resolve(exepath('dart')) | endif
  if executable('flutter')
    let l:flutter = resolve(exepath('flutter'))
    let l:flutter_bin = fnamemodify(l:flutter,':h')
    let l:dart = l:flutter_bin.'/cache/dart-sdk/bin/dart'
    if executable(l:dart) | return l:dart | endif
  endif
  echoerr 'Could not find a `dart` executable'
endfunction


function! s:SkipYamlRequests(method, params) abort
  return a:params.textDocument.uri =~? '\v\.yaml$' ?
      \ lsc#config#skip() : a:params
endfunction

function! s:HandleStatus(method, params) abort
  let g:dart_analyzer_status = a:params.isAnalyzing
endfunction
