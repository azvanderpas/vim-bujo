" bujo.vim - A minimalist todo list manager
" Maintainer:   Jersey Fonseca <http://www.jerseyfonseca.com/>
" Version:      0.5

" Get custom configs
let g:bujo#todo_file_path = get(g:, "bujo#todo_file_path", $HOME . "/.cache/bujo")
let g:bujo#window_width = get(g:, "bujo#window_width", 30)
let g:bujo#templates_file_path = expand('<sfile>:p:h:h') . "\\templates"

" Make bujo directory if it doesn't exist"
if empty(glob(g:bujo#todo_file_path))
  call mkdir(g:bujo#todo_file_path)
endif

" InGitRepository() tells us if the directory we are currently working in
" is a git repository. It makes use of the 'git rev-parse --is-inside-work-tree'
" command. This command outputs true to the shell if so, and a STDERR message
" otherwise.
"
" We will use this function to know whether we should open a specific
" project's todo list, or a global todo list.
function s:InGitRepository()
  :silent let bool = system("git rev-parse --is-inside-work-tree")

  " The git function will return true with some leading characters
  " if we are in a repository. So, we split off those characters
  " and just check the first word.
  if split(bool, '\v\n')[0] == 'true'
    return 1
  endif
endfunction


" GetToplevelFolder() gives us a clean name of the git repository that we are
" currently working in
function s:GetToplevelFolder()
  let absolute_path = system("git rev-parse --show-toplevel")
  let repo_name = split(absolute_path, "/")
  let repo_name_clean = split(repo_name[-1], '\v\n')[0]
  return repo_name_clean
endfunction


" GetBujoFilePath() returns which file path we will be using. If we are in a
" git repository, we return the directory for that specific git repo.
" Otherwise, we return the general file path.
"
" If we are passed an argument, it means that the user wants to open the
" general bujo file, so we also return the general file path in that case
function s:GetBujoFilePath(general, section)
  return g:bujo#todo_file_path . "/" . a:section . ".md"
endfunction


" OpenTodo() opens the respective todo.md file from $HOME/.cache/bujo
" If we are in a git repository, we open the todo.md for that git repository.
" Otherwise, we open the global todo file.
"
" Paramaters :
"
"   mods - allows a user to use <mods> (see :h mods)
"
"   ... - any parameter after calling :Todo will mean that the user wants
"   us to open the general file path. We check this with a:0
function s:OpenTodo(mods, ...)
  let general_bool = a:0
  let todo_path = s:GetBujoFilePath(general_bool, "todo")
  let d = strftime("%m/%d/%Y")
  if empty(glob(todo_path))
    let f = readfile(g:bujo#templates_file_path . "\\md.skeleton")
    let f[6] = substitute(f[6], "Date", d, 'g')
    call writefile(f, todo_path, 'B')
  else
    let f = readfile(todo_path)
    let arr = [d]
    if index(f, d) == -1
      let cmdStr = "python " . g:bujo#todo_file_path . "/" . "habitUpdate.py"
      let habits = split(system(cmdStr), '\n')
      let arr += habits
      let w = f[0:5] +  arr + f[6:]
      call writefile(w, todo_path, 'B')
    endif
  endif

  exe a:mods . " " . g:bujo#window_width "vs  " . todo_path
endfunction

function s:OpenMonth(mods, ...)
  let general_bool = a:0
  let month_path = s:GetBujoFilePath(general_bool, strftime("%Y%B"))
  if empty(glob(month_path))
    let y = strftime("%Y")
    let m = strftime("%B")
    call writefile([m . " " . y], month_path)
    let ndays = substitute(readfile(g:bujo#templates_file_path . "\\md.months")[0], ".*". m ."[A-z|]*\\s\\(\\d\\+\\).*","\\1", 'g')
    if m == "February" && y % 4 == 0 && (y % 100 != 0 || y % 400 == 0)
      "leap years
      let ndays = ndays + 1
    endif
    for i in range(1, ndays)
      call writefile([printf("%02d",i) . strftime("%a", localtime()-((strftime("%d")-i)*24*60*60)) ], month_path, 'a')
    endfor
  endif
  exe a:mods . " " . g:bujo#window_width "vs  " . month_path
  execute "normal /" . strftime("%d") . "\<CR>"
endfunction

function s:OpenFutureLog(mods, ...)
  let general_bool = a:0
  let future_log_path = s:GetBujoFilePath(general_bool, "FutureLog")
  if empty(glob(future_log_path))
    call writefile(readfile(g:bujo#templates_file_path . "\\md.futurelog"), future_log_path)
    for i in range(11)
      call writefile([strftime("%B %Y", localtime()-((strftime("%d")-1-i*32)*24*60*60)) ], future_log_path, 'a')
    endfor
  else
    let arr = []
    for i in range(12,0,-1)
      let d = strftime("%B %Y", localtime()-((strftime("%d")-1-i*32)*24*60*60))
      let addDate = match(readfile(future_log_path), "\\s*" . d . "\\s*")
      if addDate == -1
        let arr = [d] + arr
      else
        break
      endif
    endfor
    call writefile(arr, future_log_path, 'a')
  endif
  exe a:mods . " " . g:bujo#window_width "vs  " . future_log_path
  " Move cursor to current month
  execute "normal /" . strftime("%B %Y") . "\<CR>"
endfunction

function s:OpenHabits(mods, ...)
  let general_bool = a:0
  let habits_path = s:GetBujoFilePath(1, "Habits")
  if empty(glob(habits_path))
    call writefile(readfile(g:bujo#templates_file_path . "\\md.habits"), habits_path)
  endif
  exe a:mods . " " . g:bujo#window_width "vs  " . habits_path
endfunction

if !exists(":Todo")
  command -nargs=? Todo :call s:OpenTodo(<q-mods>, <f-args>)
endif

if !exists(":Monthly")
  command -nargs=? Monthly :call s:OpenMonth(<q-mods>, <f-args>)
endif

if !exists(":FutureLog")
  command -nargs=? FutureLog :call s:OpenFutureLog(<q-mods>, <f-args>)
endif

if !exists(":Habits")
  command -nargs=? Habits :call s:OpenHabits(<q-mods>, <f-args>)
endif





