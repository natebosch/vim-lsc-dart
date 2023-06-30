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
  if exists('g:lsc_dart_command_override')
    return g:lsc_dart_command_override
  endif
  if exists('g:lsc_dart_sdk_path')
    let l:dart = expand(g:lsc_dart_sdk_path).'/bin/dart'
    if !executable(l:dart)
      echoerr 'The path "'.l:dart.'" is not executable.'
      return v:null
    endif
  else
    let l:dart = 'dart'
  endif
  let l:cmd = [l:dart, 'language-server', '--client-id', 'vim']
  if get(g:, 'lsc_dart_enable_log', v:false)
    let l:log_file = tempname()
    call add(l:cmd, '--instrumentation-log-file='.l:log_file)
    echom 'Dart instrumentation log: '.l:log_file
  endif
  if get(g:, 'lsc_dart_enable_wirelog', v:false)
    let l:in_log = tempname()
    let l:out_log = tempname()
    let l:cmd = ['sh', '-c', 'tee '.l:in_log.' | '.join(l:cmd, ' ').' | tee '.l:out_log]
    echom 'Dart Analaysis wire logs: In: '.l:in_log.' Out: '.l:out_log
  endif
  return l:cmd
endfunction

function! s:HandleStatus(method, params) abort
  let g:dart_analyzer_status = a:params.isAnalyzing
endfunction
