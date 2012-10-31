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
pro cir_prop_sp,x0=x0,t0=t0,vel=vel,e_vel=e_vel,planets_str=planets_str,spacecraft_str=spacecraft_str
if ~keyword_set(x0) then x0=[0]; lon-lat HG
if ~keyword_set(t0) then t0 = systim()
if ~keyword_set(vel) then vel=600 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s

;===================================================================
;====================  Find if the planets are hit
if data_chk(planets_str,/type) eq 8 then $
cir_hit_object,planets_str,st_time=t0,cir_lon=x0,sw_vel=vel,sw_e_vel=e_vel

;===================================================================
;====================  Find if the s/c are hit
if data_chk(spacecraft_str,/type) eq 8 then $
cir_hit_object,spacecraft_str,st_time=t0,cir_lon=x0,sw_vel=vel,sw_e_vel=e_vel


end
