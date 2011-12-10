function wget_stream, dummy

;    form command so will return as stream to terminal rather than a file

do_wget = 0
if !hio_sysvar.wget_flag then do_wget=1

;;if !version.os eq 'darwin' $	; Mac OS

if not do_wget $
  then cmd = 'curl -s '  $
  else cmd = 'wget -qO- '	; other Linux

return, cmd
end
