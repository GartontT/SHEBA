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
function angleinrange2,ang,range,radians=radians
  if n_elements(ang) ne 1 then begin
     print,'*** angleinrange2 can just check one angle at the moment'
     return,-1
  endif
  if n_elements(range) ne 2 then begin
     print,'*** angleinrange2 needs a range of two angles'
     return,-1
  endif
  if range[0] eq range[1] then begin
     print,'*** range input is 0!'
     return,-1
  endif
  if keyword_set(radians) then begin
     ;converting values to degrees
     ang = ang/!DTOR
     range = range/!DTOR
  endif
  ang = ang mod 360.
  range = range mod 360.

  test = [0,0]
  while total(test) ne 2 do begin
     if range[0] lt range[1] then test[0] = 1 else range[0]-= 360
     if not ((range[0] lt 0) and (range[1] lt 0)) then test[1] = 1 else range += 360
  endwhile

  if ((range[1] ge ang) and (range[0] le ang)) then return,1 else return,0

end
