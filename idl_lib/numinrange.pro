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
function numinrange,num,array
if ((n_elements(num) gt 1)) then begin
   print,'%% NumInRange needs a single value as to find if is in range'
   return,-1
endif
if (n_elements(array) ne 2)then begin
   print,'%% NumInRange needs a two elements array to define the range'
   return,-1
endif

;;TODO check that there is one value for num and two values for array

value_min = (num ge min(array))?1b:0b
value_max = (num le max(array))?1b:0b 

return, (value_min and value_max)
end

