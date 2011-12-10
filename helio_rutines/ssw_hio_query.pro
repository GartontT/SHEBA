function ssw_hio_query, command, convert_votable=convert_votable, verbose=verbose

message,'Submitting query to HELIO Service',/info

;    assemble command with "wget" dependant on the operating system
cmd = wget_stream() + '"' + command + '"'
if keyword_set(verbose) then print,cmd

;    issue command and retrieve response
spawn, cmd, resp

;    STILTs puts an undesirable line at start and end
p1 = where(strpos(resp,'sql> ') eq 0, np1)
p2 = where(strpos(resp,'Elapsed time: ') eq 0, np2)
;print,p1,p2 & help,resp

stilts_out = resp
if np1 eq 1 and np2 eq 1 then stilts_out = resp(p1(0)+1:p2(0)-1)

if keyword_set(convert_votable) then begin
  message,'VOTable conversion requested',/info
  stilts_out = decode_votable(stilts_out, quiet=1-keyword_set(verbose))
endif

return, stilts_out
end