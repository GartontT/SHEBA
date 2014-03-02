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
pro cme_prop_sp,x_sol=x_sol,t_sol=t_sol,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,planets_str=planets_str,spacecraft_str=spacecraft_str,cme_val=cme_val
if ~keyword_set(t_sol) then t_sol = systim()
if ~keyword_set(cme_vel) then cme_vel=800 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s
if (n_elements(x_sol) ne 2) then x_sol=[0,0]; lon-lat HGI
if (n_elements(dlong) eq 0) then dlong=45

cme_lon = long_hgihg(x_sol[0],/hg,date=t_sol) ;degrees

;===================================================================
;====================  Obtain properties of planets and spacecraft
;ellip = planet_orbit(t_sol,3,planet=earth,all_planets=all_planets)
;all_spacecraft  = spacecraft_path(t_sol,drange=300)

;===================================================================
;====================  Find if the planets are hit
cme_hit_object,planets_str,st_time=t_sol,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme_planets

;===================================================================
;====================  Find if the s/c are hit
if data_chk(spacecraft_str,/type) eq 8 then $
cme_hit_object,spacecraft_str,st_time=t_sol,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme_spacecraft


cme_val = (n_elements(cme_spacecraft) gt 0)?[cme_planets,cme_spacecraft]:cme_planets
;planets_str = all_planets
;spacecraft_str = all_spacecraft
;....
end
