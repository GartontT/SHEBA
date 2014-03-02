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
pro cme_planet_hit,planet_str,st_time=st_time,cme_lon=cme_lon,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,cme_val=cme_val

;===================================================================
;====================  Find where the CME intersect the planet orbit
inter = intersect_ellipline(planet_str.orbit_fit,[tan(cme_lon * !DtoR),0],angle=cme_lon)


;===================================================================
;=============== Calculate the time it takes to the CME to get there
rad = sqrt(total(inter^2)); radius[AU]
cme_t = (rad *  150e6) / cme_vel              ; (radius[AU] * km/[AU] ) / km/s
cme_t1 = anytim(anytim(st_time)+cme_t,/CCSDS) ; Starting_time + travel_time

; and the velocity errors:
cme_tn = (rad *  150e6) / (cme_vel-e_vel)     ; (radius[AU] * km/[AU] ) / km/s
cme_t1n = anytim(anytim(st_time)+cme_tn,/CCSDS) ; Starting_time + travel_time
; and the velocity errors:
cme_tp = (rad *  150e6) / (cme_vel+e_vel)     ; (radius[AU] * km/[AU] ) / km/s
cme_t1p = anytim(anytim(st_time)+cme_tp,/CCSDS) ; Starting_time + travel_time


;===================================================================
;================ Calculate position of planet at the time of impact
jd_struct = anytim2jd(cme_t1)
jd = jd_struct.int + jd_struct.frac

helio, jd, planet_str.n, planet_t1_rad, planet_t1_lon, planet_t1_lat

year = (strsplit(anytim(cme_t1,/ecs),'/',/extract))[0]
long_asc_node = 74+(22.+((year-1900)*.84))/60.
planet_t1_lon = planet_t1_lon - long_asc_node 

polrec,planet_t1_rad,planet_t1_lon,planet_t1_x,planet_t1_y,/degrees

planet_str.pos_thit.date    = anytim(jd2ecs(jd),/CCSDS)
planet_str.pos_thit.radio   = planet_t1_rad
planet_str.pos_thit.lon     = planet_t1_lon
planet_str.pos_thit.lat     = planet_t1_lat
planet_str.pos_thit.orbit_x = planet_t1_x
planet_str.pos_thit.orbit_y = planet_t1_y

;===================================================================
;================ Fill in input parameters
planet_str.input.st_time     = anytim(st_time,/CCSDS)
planet_str.input.st_long     = long_hgihg(cme_lon,/ihg,date=st_time)
planet_str.input.st_long_hci = cme_lon
planet_str.input.width       = dlong
planet_str.input.cme_vel     = cme_vel
planet_str.input.cme_vel_e   = e_vel

;===================================================================
;================ Fill in min and max expected times
planet_str.minmaxt.t_min     = cme_t1p
planet_str.minmaxt.t_max     = cme_t1n

;===================================================================
;====================== Calculate whether it hits or miss the planet
planet_str.HitOrMiss = angleinrange(cme_lon,dlong,planet_t1_lon)

;===================================================================
;================  Output cme_val variable array
cme_val = [cme_t/(3600.*24.),rad] ; [days,au]


end
