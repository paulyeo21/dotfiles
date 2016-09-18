function! MergeTab()
  " Tab pages are not zero index
  if tabpagenr() == 1
    close!
  endif

  let bufferName = bufname("%")
  " Is the last tab the current tab
  if tabpagenr("$") == tabpagenr()
    close!
  else
    close!
    tabprev
  endif

  split
  " Arguments to internal commands don't get commas
  " execute adds spaces for you, unless you use '.'
  execute "buffer" bufferName
endfunction

