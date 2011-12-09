pro scsym,psize,fill=fill,thick=thick,rot=rot

;
; Rot -> rotation in degrees

if n_elements(psize) eq 0 then psize=1
;create circle:
  csize=0.35
    ang = 2*!PI*findgen(23)/24.     
    xarr = csize*cos(ang)  &  yarr = csize*sin(ang)
;create panels at 45deg
    xarr_r = [xarr[0:24/8],1,1,xarr[24/8],reverse(xarr[5*24/8:7*24/8]),-1,-1,xarr[3*24/8]]
    yarr_r = [yarr[0:24/8],yarr[24/8],yarr[7*24/8],yarr[7*24/8],reverse(yarr[5*24/8:7*24/8]),yarr[5*24/8],yarr[3*24/8],yarr[3*24/8]]
    
    xarr=[xarr,xarr_r]*psize
    yarr=[yarr,yarr_r]*psize

if n_elements(rot) eq 1 then begin
   rot = rot*!DToR
   xarr_r = xarr
   yarr_r = yarr
   xarr = cos(rot)*xarr_r-sin(rot)*yarr_r
   yarr = sin(rot)*xarr_r+cos(rot)*yarr_r
endif


usersym, xarr, yarr, FILL = fill,thick=thick

return
end
