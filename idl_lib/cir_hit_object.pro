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
pro cir_hit_object,objects,st_time=st_time,cir_lon=cir_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel

  for i=0,n_elements(objects)-1 do begin

;;===================== a planet ==================
     if tag_exist(objects[i],'orbit_fit') then begin
        planet_i = objects[i]
        cir_planet_hit,planet_i,st_time=st_time,cir_lon=cir_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel
        objects[i] = planet_i
        
;;===================== a s/c =====================
     endif else begin
        sc_i = objects[i]
        cir_spacecraft_hit,sc_i,st_time=st_time,cir_lon=cir_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel
        objects[i] = sc_i
      endelse

  endfor

end
