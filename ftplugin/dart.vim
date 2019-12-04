if !exists('s:initialized')
  call lsc#dart#register()
  let s:initialized = v:true
endif

command! -buffer -nargs=0 DartAnalysisServerDiagnostics
    \ call <SID>DartDiagnosticServer()

function! s:DartDiagnosticServer() abort
  call lsc#server#userCall('dart/diagnosticServer', v:null,
      \ function("<SID>EchoServerUrl"))
endfunction

function! s:EchoServerUrl(result) abort
  echom 'Analysis Server Diagnostics: http://localhost:'.string(a:result.port)
endfunction
