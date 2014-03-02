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
function arcdist,rad_arr,ang_arr
;-
; Calculate the distance along an arc from curvilinear
; coordinates, i.e. radius, angle (deg)
;  IDL> ang = findgen(1000)/1000. * 180
;  IDL> rad = cos(ang * !DToR)
;  IDL> print,arcdist(rad,ang)
;      3.13844
;  IDL> print, !pi  
;      3.14159
;
;+
  nrad = n_elements(rad_arr)
  nang = n_elements(ang_arr)
  if nrad ne nang then return,-1
  
  x = fltarr(nrad)
  y = x
  for i = 0, nrad-1 do begin
     polrec,rad_arr[i],ang_arr[i],xi,yi,/deg
     x[i]=xi
     y[i]=yi
     dist = (i ne 0)? sqrt((x[i]-x[i-1])^2 + (y[i]-y[i-1])^2)+dist:0
  endfor


return,dist
end
