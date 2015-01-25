let g:PlayPausePlayer = "none"
let g:PlayPauseState  = "none"

function! s:Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)[\n\s\r]*$', '\1', '')
endfunction

function! s:DetectPlayer()
  let spotify_state = s:Strip(s:SystemCallWrapper("osascript -e 'tell application \"Spotify\" to return the player state'"))
  if spotify_state == "playing"
    let g:PlayPausePlayer = "spotify"
    let g:PlayPauseState  = "playing"
  endif

  let itunes_state = s:Strip(s:SystemCallWrapper("osascript -e 'tell application \"iTunes\" to return the player state'"))
  if itunes_state == "playing"
    let g:PlayPausePlayer = "itunes"
    let g:PlayPauseState  = "playing"
  endif
endfunction

function! s:SystemCallWrapper(command)
  let result = system(a:command)
  if v:shell_error
    throw "Non zero exit code [" . v:shell_error . "] from: " . a:command
  endif
  return result
endfunction

function! s:PlayPauseCaller(player, play, pause)
  if g:PlayPauseState == "playing"
    let g:PlayPauseState = "pause"
    call s:SystemCallWrapper(a:play)
    echo "Paused " . a:player
  else
    call s:SystemCallWrapper(a:pause)
    let g:PlayPausePlayer = "none"
    let g:PlayPauseState  = "none"
    echo "Resumed " . a:player
  endif
endfunction

function! s:PlayPauseItunes()
  call s:PlayPauseCaller("iTunes",
        \"osascript -e 'tell application \"iTunes\" to pause'",
        \"osascript -e 'tell application \"iTunes\" to play'")
endfunction

function! s:PlayPauseSpotify()
  call s:PlayPauseCaller("Spotify",
        \"osascript -e 'tell application \"Spotify\" to pause'",
        \"osascript -e 'tell application \"Spotify\" to play'")
endfunction

function! PlayPausePlayer()
  if g:PlayPausePlayer == "none"
    call s:DetectPlayer()
  endif

  if g:PlayPausePlayer == "itunes"
    call s:PlayPauseItunes()
  elseif g:PlayPausePlayer == "spotify"
    call s:PlayPauseSpotify()
  else
    echo "No active player found"
  endif
endfunction

function! ResetPlayPause()
  let g:PlayPausePlayer = "none"
endfunction

command! -nargs=* PlayPause call PlayPausePlayer()
command! -nargs=* ResetPlayPause call ResetPlayPause()
