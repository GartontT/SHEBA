;==================================================================
;Copyright 2011, 2012  David Pérez-Suárez (TCD-HELIO)
;===================GNU license====================================
;This file is part of SHEBA.
;
;    SHEBA is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    SHEBA is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with SHEBA.  If not, see <http://www.gnu.org/licenses/>.
;==================================================================
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
