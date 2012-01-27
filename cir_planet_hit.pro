pro cir_planet_hit,planet_str,st_time=st_time,cir_lon=cir_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel


vel = sw_vel + [-1,0,1]*sw_e_vel
rot_sun = 14.4

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


end
