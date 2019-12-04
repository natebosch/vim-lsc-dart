if !exists('s:initialized')
  call lsc#dart#register()
  let s:initialized = v:true
endif
