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
pro cir_planet_hit,planet_str,st_time=st_time,cir_lon=cir_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel


vel = sw_vel + [-1,0,1]*sw_e_vel
rot_sun = 14.4

planet_str.input.st_time     = anytim(st_time,/CCSDS)
planet_str.input.st_long     = cir_lon
planet_str.input.st_long_hci = long_hgihg(cir_lon,/hg,date=st_time)
planet_str.input.width       = 0
planet_str.input.cme_vel     = 0
planet_str.input.cme_vel_e   = 0
planet_str.input.sw_vel = sw_vel
planet_str.input.sw_vel_e = sw_e_vel

for i=0,2 do begin
   time = st_time
   control_ang = 100
   plon=0
   while control_ang gt 0.1 do begin
      plon_1 = plon
      cir_prop_ps,planetn=planet_str.N,t_planet=time,sw_vel=vel[i],cir_lon=plon,t_sun=tsun
      print,plon
      delta_ang = pm180(plon) - pm180(cir_lon)
      delta_time = (delta_ang / rot_sun) * 24. * 3600. ;sec

      time = anytim(anytim(st_time) + delta_time,/CCSDS)
      control_ang = plon - plon_1
   endwhile

   if i eq 1 then begin
      
      planet_str.pos_thit.date = time
      planet_str.pos_thit.sw_vel = vel[i]
      planet_str.pos_thit.sw_vel_au = vel[i]*24.*3600./150e6
      planet_str.pos_thit.delta_time = delta_time/60./60./24. ;days

   endif
   if i eq 0 then planet_str.minmaxt.t_max = time
   if i eq 2 then planet_str.minmaxt.t_min = time

endfor


; fill the structure  with pos_thit variables
jd_struct = anytim2jd(planet_str.pos_thit.date)
jd = jd_struct.int + jd_struct.frac
helio, jd, planet_str.N, planet_t1_rad, planet_t1_lon, planet_t1_lat
year = (strsplit(anytim(planet_str.pos_thit.date,/ecs),'/',/extract))[0]
long_asc_node = 74+(22.+((year-1900)*.84))/60.
planet_t1_lon = planet_t1_lon - long_asc_node 
polrec,planet_t1_rad,planet_t1_lon,orb_x,orb_y,/degrees

      planet_str.pos_thit.radio = planet_t1_rad
      planet_str.pos_thit.lon = planet_t1_lon
      planet_str.pos_thit.lat = planet_t1_lat
      planet_str.pos_thit.orbit_x = orb_x
      planet_str.pos_thit.orbit_y = orb_y
      planet_str.HitOrMiss = 1b


end
