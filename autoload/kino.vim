let s:shown=0
let s:win_id=0
let s:sub_id=0
let s:port="null"
let s:speed="115200"
let s:baudrate=[9600,115200]
let s:serial_flag=0
let s:config_winid=0
hi! blue ctermbg=cyan guibg=#00ffff
hi! selected_background ctermbg=90 ctermfg=black guibg=#ff5599 guifg=#000000
function s:init()
  let s:width=nvim_get_option("columns")
  let s:height=nvim_get_option("lines")
  let s:winconf={"style":"minimal","relative":"editor","width":s:width*3/4,"height":s:height*3/4,"row":s:height/8,"col":s:width/8,"focusable":v:false}
  let s:subconf={"style":"minimal","relative":"editor","width":s:width*3/4+4,"height":s:height*3/4+2,"row":s:height/8-1,"col":s:width/8-2,"focusable":v:false}
endfunction
call s:init()

function kino#Clear()
  call s:CloseWin()
  call s:CreateWin(s:subconf,s:winconf)
  term platformio run --target erase
  normal G
endfunction

function kino#Upload()
  call s:CloseWin()
  call s:CreateWin(s:subconf,s:winconf)
  term platformio run --target upload
  normal G
endfunction

function kino#Serial()
  call s:CloseWin()
  if s:port!="null" && s:speed!=""
    call s:CreateWin(s:subconf,s:winconf)
    set number
    execute "term screen ".s:port." ".s:speed
  else
    let s:serial_flag=1
    call s:serial_config()
  endif
endfunction

function kino#SerialConf()
  call s:serial_config()
endfunction

function s:serial_config()
  let conf2=copy(s:subconf)
  let conf1=copy(s:winconf)
  let g:kino_ports=split(system("ls /dev/tty*"),"\n")
  let conf1.col=s:width/4
  let conf2.col=conf1.col-2
  let conf1.width=s:width*3/8
  let conf2.width=conf1.width+4
  let conf1.height=3
  let conf2.height=conf1.height+2
  let g:config_winid=s:CreateWin(conf2,conf1)
  call setline(1,"Port     ".s:port)
  call setline(2,"BaudRate ".s:speed)
  call setline(3,"         OK")
  nnoremap <buffer> l <Nop>
  nnoremap <buffer> h <Nop>
  nnoremap <buffer> i <Nop>
  nnoremap <buffer> a <Nop>
  nnoremap <buffer> o <Nop>
  nnoremap <buffer> j j
  nnoremap <buffer> k k
  nnoremap <buffer> <Return> :call <SID>select(g:kino_ports)<CR>
  normal w
  call matchadd("blue",s:port)
  call matchadd("blue",s:speed)
endfunction

function s:select(ports)
  let p=getcurpos()[1]
  if p==1
    call s:CreateMenu(a:ports)
  elseif p==2
    call s:CreateMenu(s:baudrate)
  else
    q
  endif
endfunction

function s:CreateMenu(menus)
  autocmd! WinClosed *
  let p=getcurpos()
  let conf={"style":"minimal","relative":"editor","width":s:width/4,"height":len(a:menus),"row":s:height/8+p[1],"col":s:width/4+p[2]-1,"focusable":v:false}
  let s:menu_id=nvim_open_win(nvim_create_buf(v:false,v:true),v:true,conf)
  call nvim_win_set_option(s:menu_id,"winhighlight","Normal:selected_background")
  call setline(1,a:menus)
  nnoremap <buffer> j j
  nnoremap <buffer> k k
  nnoremap <buffer> <ESC> :call <SID>CloseMenu("")<CR>
  nnoremap <buffer> <Return> :call <SID>CloseMenu(getline(getcurpos()[1]))<CR>
endfunction

function s:CloseMenu(result)
  q
  call win_gotoid(g:config_winid)
  if a:result!=""
    let p=getcurpos()
    if p[1]==1
      let s:port=a:result
    else
      let s:speed=a:result
    endif
    call setline(1,"Port     ".s:port)
    call setline(2,"BaudRate ".s:speed)
    call matchadd("blue",s:port)
    call matchadd("blue",s:speed)
    if s:serial_flag==1
      call kino#Serial()
      let s:serial_flag=0
    endif
  endif
  autocmd! WinClosed * :call s:CloseWin()
endfunction

function kino#Build()
  call s:CloseWin()
  call s:CreateWin(s:subconf,s:winconf)
  term platformio run
  normal G
endfunction

function s:CreateWin(subconf,winconf)
  call s:init()
  if s:shown
    call s:CloseWin()
  endif
  hi! kino_background ctermbg=239 ctermfg=255
  hi! kino_background2 ctermbg=237
  let s:shown=1
  let s:sub_id=nvim_open_win(nvim_create_buf(v:false,v:true),v:true,a:subconf)
  call nvim_win_set_option(s:sub_id,"winhighlight","Normal:kino_background2")
  let s:win_id=nvim_open_win(nvim_create_buf(v:false,v:true),v:true,a:winconf)
  call nvim_win_set_option(s:win_id,"winhighlight","Normal:kino_background")
  let s:win_num=buffer_number()
  nnoremap <buffer> <nowait> <silent> <ESC> :q<CR>
  nnoremap <buffer> <silent> o <Nop>
  tnoremap <buffer> <ESC> <C-\><C-n>
  autocmd! WinClosed * :call s:CloseWin()
endfunction

function s:CloseWin()
  if s:shown
    execute "close ".s:win_num
    execute "close ".(s:win_num+1)
    let s:shown=0
  endif
  autocmd! WinClosed *
endfunction

function kino#ReturnWindow()
  call win_gotoid(s:win_id)
endfunction
