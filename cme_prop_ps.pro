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
pro cme_prop_ps,planetn=planetn,t_planet=t_planet,cme_vel=cme_vel,cme_lon=cme_lon,t_sun=t_sun
if ~keyword_set(planetn) then planetn = 3
if ~keyword_set(t_planet) then t_planet = systim()
if ~keyword_set(cme_vel) then cme_vel=800 ;km/s

;===================================================================
;==================== Find planet position                      ;;***  find whether a ihg coord are input (sc)
jd_struct = anytim2jd(t_planet)
jd = jd_struct.int + jd_struct.frac
helio, jd, planetn, planet_t1_rad, planet_t1_lon, planet_t1_lat
year = (strsplit(anytim(t_planet,/ecs),'/',/extract))[0]
long_asc_node = 74+(22.+((year-1900)*.84))/60.
planet_t1_lon = planet_t1_lon - long_asc_node 

;===================================================================
;=============== Calculate the time it takes to the CME to get there
cme_t = (planet_t1_rad *  150e6) / cme_vel   ; (radius[AU] * km/[AU] ) / km/s
t_sun = anytim(anytim(t_planet)-cme_t,/CCSDS)           ; Starting_time + travel_time
  ; and plot it
  ;xyouts,0,0,t_sol
  ;xyouts,inter[0],inter[1],anytim(cme_t1,/YOHKOH)

;===================================================================
;=============== Calculate the position on the sun
cme_lon = long_hgihg(planet_t1_lon,/ihg,date=t_sun) ;degrees

print,' CME lon '+string(cme_lon)
print,' Time    '+anytim(t_sun,/YOHKOH)

end
