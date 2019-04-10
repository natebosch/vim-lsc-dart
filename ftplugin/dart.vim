if exists('s:initialized')
  finish
endif
let s:initialized = v:true

function! s:FindCommand() abort
  let l:dart = exepath('dart')
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
  return ['dart', l:snapshot, '--lsp']
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
      \   }
      \ }
      \}
  call RegisterLanguageServer('dart', l:config)
  call RegisterLanguageServer('yaml', 'Dart Analysis Server')
endfunction

call s:RegisterDartServer()
