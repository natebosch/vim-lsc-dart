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
  if exists('g:lsc_dart_sdk_path')
    let l:bin = expand(g:lsc_dart_sdk_path).'/bin'
    let l:dart = l:bin.'/dart'
    if !executable(l:dart)
      echoerr 'The path "'.l:dart.'" is not executable.'
    endif
  else
    let l:dart = s:FindDart()
    if type(l:dart) != type('') | return v:null | endif
    let l:bin = fnamemodify(l:dart, ':h')
  endif
  let l:snapshot = l:bin.'/snapshots/analysis_server.dart.snapshot'
  if !filereadable(l:snapshot)
    echoerr 'Could not find analysis server snapshot at '.l:snapshot
    return v:null
  endif
  let l:cmd = [l:dart, l:snapshot, '--lsp', '--client-id', 'vim']
  if get(g:, 'lsc_dart_enable_completion_ml', v:true)
    let l:language_model = l:bin.'/model/lexeme'
    if isdirectory(l:language_model)
      call add(l:cmd, '--completion-model='.l:language_model)
    endif
  endif
  if get(g:, 'lsc_dart_enable_log', v:false)
    let l:log_file = tempname()
    call add(l:cmd, '--instrumentation-log-file='.l:log_file)
    echom 'Dart instrumentation log: '.l:log_file
  endif
  return l:cmd
endfunction

function! s:FindDart() abort
  if !executable('dart') && !executable('flutter')
    echoerr 'Could not find either a `dart` or `flutter` command. '
        \.'Your $PATH must contain either the Dart of Flutter bin directory.'
    return v:false
  endif
  if executable('dart')
    let l:dart = resolve(exepath('dart'))
    let l:bin = fnamemodify(l:dart, ':h')
    if !executable(l:bin.'/flutter')
      return l:dart
    endif
  endif
  let l:flutter = resolve(exepath('flutter'))
  let l:flutter_bin = fnamemodify(l:flutter,':h')
  let l:dart = l:flutter_bin.'/cache/dart-sdk/bin/dart'
  if executable(l:dart) | return l:dart | endif
  echoerr 'Could not find the Dart SDK.'
endfunction

function! s:HandleStatus(method, params) abort
  let g:dart_analyzer_status = a:params.isAnalyzing
endfunction
