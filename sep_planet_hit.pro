pro sep_planet_hit,planet_str,st_time=st_time,sep_lon=sep_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel

;==============================
;===== Calculate time in JD for helio
jd_struct = anytim2jd(st_time)
jd = jd_struct.int + jd_struct.frac

helio, jd, planet_str.n, planet_t1_rad, planet_t1_lon, planet_t1_lat

year = (strsplit(anytim(st_time,/ecs),'/',/extract))[0]
long_asc_node = 74+(22.+((year-1900)*.84))/60.
planet_t1_lon = planet_t1_lon - long_asc_node 

polrec,planet_t1_rad,planet_t1_lon,planet_t1_x,planet_t1_y,/degrees

planet_str.pos_thit.date    = anytim(jd2ecs(jd),/CCSDS)
planet_str.pos_thit.radio   = planet_t1_rad
planet_str.pos_thit.lon     = planet_t1_lon   ;hci
planet_str.pos_thit.lat     = planet_t1_lat
planet_str.pos_thit.orbit_x = planet_t1_x
planet_str.pos_thit.orbit_y = planet_t1_y

;===================================================================
;================ Fill in input parameters
planet_str.input.st_time     = anytim(st_time,/CCSDS)
planet_str.input.st_long     = sep_lon
planet_str.input.st_long_hci = long_hgihg(sep_lon,/hg,date=st_time)
planet_str.input.width       = 0
planet_str.input.cme_vel     = 0
planet_str.input.cme_vel_e   = 0
planet_str.input.sw_vel      = sw_vel
planet_str.input.sw_vel_e    = sw_e_vel


;====================================================
;============== Calculate velocity needed for hitting.
rot_sun = 14.4
vel_wind = sw_vel+[-1,1]*sw_e_vel
vel_wind_au = ( vel_wind / 150e6 ) * 24. * 60. * 60.

diff_angle = posang(planet_str.input.st_long_hci - planet_str.pos_thit.lon)
vel_2hitPlanet = (planet_str.pos_thit.radio) * rot_sun / diff_angle

while vel_2hitPlanet gt max(vel_wind_au) do begin
   diff_angle = diff_angle + 360
   vel_2hitPlanet = (planet_str.pos_thit.radio) * rot_sun / diff_angle
endwhile

planet_str.pos_thit.spiral_angle = diff_angle
planet_str.pos_thit.sw_vel_au = vel_2hitPlanet
planet_str.pos_thit.sw_vel = vel_2hitPlanet * 150e6 / (24.*60.*60.)
;===================================================================
;====================== Calculate whether it hits or miss the planet
planet_str.HitOrMiss = numinrange(vel_2hitPlanet,vel_wind_au)

end
