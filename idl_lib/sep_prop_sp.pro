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
pro sep_prop_sp,x0=x0,t0=t0,vel=vel,e_vel=e_vel,beta=beta,planets_str=planets_str,spacecraft_str=spacecraft_str
if ~keyword_set(t0) then t0 = systim()
if ~keyword_set(vel) then vel=400 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s
if ~keyword_set(x0) then x0=[0]; lon-lat HG
if ~keyword_set(beta) then beta=0.9
beta=abs(beta) ;c times! relativistic particles

;; Make sure that the values are positive
vel=abs(vel)
e_vel = abs(e_vel)

;; --- Here it differs from the CME because the starting point is not
;;     changed to HGI.

;===================================================================
;====================  Find if the planets are hit
if data_chk(planets_str,/type) eq 8 then $
sep_hit_object,planets_str,st_time=t0,sep_lon=x0,sw_vel=vel,sw_e_vel=e_vel,beta=beta


;===================================================================
;====================  Find if the s/c are hit
if data_chk(spacecraft_str,/type) eq 8 then $
sep_hit_object,spacecraft_str,st_time=t0,sep_lon=x0,sw_vel=vel,sw_e_vel=e_vel,beta=beta

end
