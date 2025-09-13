if exists("g:loaded_kino")
  finish
endif
let g:loaded_kino=1

nmap <Plug>(kino_serial) :call kino#Serial()<CR>
nmap <Plug>(kino_build) :call kino#Build()<CR>
nmap <Plug>(kino_upload) :call kino#Upload()<CR>
nmap <Plug>(kino_serial_config) :call kino#SerialConf()<CR>
nmap <Plug>(kino_clear) :call kino#Clear()<CR>
