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
function str_hist, array,uniqstr=uniqstr
  hist=intarr(1)
  hist[0]=1
  uniqstrings=strarr(1)
  uniqstrings[0]=array[0]
  for i=1, n_elements(array)-1 do begin
     idx=where(uniqstrings eq array[i])
     if (idx eq -1) then begin  ; found new string
        uniqstrings=[uniqstrings,array[i]]
        hist=[hist,1]
     endif else begin
        hist[idx]++
     endelse
  endfor

  uniqstr = uniqstrings
  return, hist
end
