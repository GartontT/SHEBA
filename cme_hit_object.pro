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
pro cme_hit_object,objects,st_time=st_time,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme_val

  for i=0,n_elements(objects)-1 do begin

;;===================== a planet ==================
     if tag_exist(objects[i],'orbit_fit') then begin
         planet_i = objects[i]
        cme_planet_hit,planet_i,st_time=st_time,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme
        objects[i] = planet_i
        if n_elements(cme) ne 0 then cme_val = (n_elements(cme_val) eq 0)?cme:[cme_val,cme]

;;===================== a s/c =====================
     endif else begin
        sc_i = objects[i]
        cme_spacecraft_hit,sc_i,st_time=st_time,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme
        objects[i] = sc_i
        if n_elements(cme) ne 0 then cme_val = (n_elements(cme_val) eq 0)?cme:[cme_val,cme]

     endelse

  endfor
;....
end
