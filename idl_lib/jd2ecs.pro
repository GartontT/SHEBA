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
function jd2ecs,jd
;+
; from a jd date produces a ECS format date: 
;    1998/05/23 10:11:34.432
;-

  daycnv,jd,yr,mn,d,hr
  min = (hr -fix(hr)) * 60.  
  seg = (min - fix(min)) * 60.

  if n_elements(jd) eq 1 then begin
     date = string(yr,mn,d,fix(hr),fix(min),seg, $
                   format = '(I4.4,2("/",I2.2)," ",2(I2.2,":"),F06.3)')
  endif else begin
     date = strarr(n_elements(jd))
     for i=0,n_elements(jd)-1 do date[i]=string(yr[i],mn[i],d[i],fix(hr[i]),fix(min[i]),seg[i], $
                   format = '(I4.4,2("/",I2.2)," ",2(I2.2,":"),F06.3)')
  endelse

  return,date
end

