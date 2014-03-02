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
pro prop_cir_back,object=object,t0=t0,vel=vel,e_vel=e_vel,PATH_OUT=PATH_OUT
if ~keyword_set(object) then object='EARTH' else object=strupcase(object)
if ~keyword_set(t0) then t0 = anytim(systim(),/ccs) else t0=anytim(t0,/ccs)
if ~keyword_set(vel) then vel=600 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s
if ~keyword_set(path_out) then path_out = '/tmp/'

planets    =  ['MERCURY','VENUS','EARTH','MARS','JUPITER',$
               'SATURN','URANUS','NEPTUNE','PLUTO']
spacecraft = ['Ulysses','StereoA','StereoB','Messenger',$
             'Voyager1','Voyager2','Galileo','Cassini',$
             'NewHorizons','Rosetta','Dawn']
planet_lab = where(object eq planets,nplanet)
spacecraft_lab = where(object eq strupcase(spacecraft),nspacecraft)

if nplanet ne 0 then $
   cir_prop_ps,planetn=planet_lab+1,t_planet=t0,sw_vel=vel,cir_lon=cir_lon,t_sun=t_sun

if nspacecraft ne 0 then $
   cir_prop_os,object=object,t_object=t0,sw_vel=vel,cir_lon=cir_lon,t_sun=t_sun

;if ILS fails then run the same query but using Earth
if n_elements(cir_lon) eq 0 then $
   prop_cir_back,t0=t0,vel=vel,e_vel=e_vel,PATH_OUT=PATH_OUT $
else $
  sheba_run,model='cir',time_sol=t_sun,x0=cir_lon,vel=vel,e_vel=e_vel,PATH_OUT=PATH_OUT




end
