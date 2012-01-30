pro cir_spacecraft_hit,spacecraft_str,st_time=st_time,cir_lon=cir_lon,sw_vel=sw_vel,sw_e_vel=sw_e_vel

time_diff = (anytim(spacecraft_str.orbit_steps.date)-anytim(st_time))
spacecraft_exist = (min(time_diff) lt 2*3600*24.)?1b:0b

if spacecraft_exist then begin

;===================================================================
;================ Fill in input parameters
   spacecraft_str.input.st_time     = anytim(st_time,/CCSDS)
   spacecraft_str.input.st_long     = cir_lon
   spacecraft_str.input.st_long_hci = long_hgihg(cir_lon,/hg,date=st_time)
   spacecraft_str.input.width       = 0
   spacecraft_str.input.cme_vel     = 0
   spacecraft_str.input.cme_vel_e   = 0
   spacecraft_str.input.sw_vel      = sw_vel
   spacecraft_str.input.sw_vel_e    = sw_e_vel
   spacecraft_str.HitOrMiss         = 1b

;=================================================================
;================= Using same technique that for the planets...

   vel = sw_vel + [-1,0,1]*sw_e_vel
   rot_sun = 14.4

   for i=0,2 do begin
      time = st_time
      control_ang = 100
      plon=0
      while control_ang gt 0.1 do begin
         plon_1 = plon
         cir_prop_os,object= spacecraft_str.name,t_object=time,sw_vel=vel[i],cir_lon=plon,t_sun=tsun
         print,plon
         delta_ang = pm180(plon) - pm180(cir_lon)
         delta_time = (delta_ang / rot_sun) * 24. * 3600. ;sec

         time = anytim(anytim(st_time) + delta_time,/CCSDS)
         control_ang = plon - plon_1
      endwhile

      if i eq 1 then begin
         
         spacecraft_str.pos_thit.date = tsun
         spacecraft_str.pos_thit.sw_vel = vel[i]
         spacecraft_str.pos_thit.sw_vel_au = vel[i]*24.*3600./150e6
         spacecraft_str.pos_thit.delta_time = (anytim(tsun)-anytim(st_time))/60./60./24. ;days

      endif
      if i eq 0 then spacecraft_str.minmaxt.t_max = anytim(tsun,/CCSDS)
      if i eq 2 then spacecraft_str.minmaxt.t_min = anytim(tsun,/CCSDS)

   endfor

   lab = where(spacecraft_str.pos_thit.date eq spacecraft_str.orbit_steps.date,ll)
   if ll ne 0 then begin

      spacecraft_str.pos_thit.radio = spacecraft_str.orbit_steps.radio[lab]
      spacecraft_str.pos_thit.lon = spacecraft_str.orbit_steps.lon[lab]
      spacecraft_str.pos_thit.lat = spacecraft_str.orbit_steps.lat[lab]
      spacecraft_str.pos_thit.orbit_x = spacecraft_str.orbit_steps.orbit_x[lab]
      spacecraft_str.pos_thit.orbit_y = spacecraft_str.orbit_steps.orbit_y[lab]
      spacecraft_str.HitOrMiss = 1b

   endif else begin

;get the data again from the net
   endelse
endif


end
