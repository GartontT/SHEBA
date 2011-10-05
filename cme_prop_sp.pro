pro cme_prop_sp,planetn=planetn,x_sol=x_sol,t_sol=t_sol,cme_vel=cme_vel,e_vel=e_vel,dlong=dlong,planet_out=planet_out,cme_val=cme_val
if ~keyword_set(planetn) then planetn = 3
if ~keyword_set(t_sol) then t_sol = systim()
if ~keyword_set(cme_vel) then cme_vel=800 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s
if ~keyword_set(x_sol) then x_sol=[0,0]; lon-lat HGI
if ~keyword_set(dlong) then dlong=2 ; width in deg

cme_lon = long_hgihg(x_sol[0],/hg,date=t_sol) ;degrees
;print,cme_lon
;===================================================================
;====================  Find where the CME intersect the planet orbit
ellip = planet_orbit(t_sol,planetn,planet=planet)
inter = intersect_ellipline(ellip,[tan(cme_lon * !DtoR),0],angle=cme_lon)
;inter_a = intersect_ellipline(ellip,[tan(cme_lon+dlong/2 * !DtoR),0],angle=cme_lon+dlong/2,/plot)
;inter_b = intersect_ellipline(ellip,[tan(cme_lon-dlong/2 * !DtoR),0],angle=cme_lon-dlong/2,/plot)
  ; and plot it
;  plot,planet.orbit.orbit_x,planet.orbit.orbit_y,psym=4
;  oplot,[0,inter[0]],[0,inter[1]]

;===================================================================
;=============== Calculate the time it takes to the CME to get there
rad = sqrt(total(inter^2)); radius[AU
cme_t = (rad *  150e6) / cme_vel   ; (radius[AU] * km/[AU] ) / km/s
cme_t1 = anytim(anytim(t_sol)+cme_t,/ccs)           ; Starting_time + travel_time

; and the velocity errors:
cme_tn = (rad *  150e6) / (cme_vel-e_vel)   ; (radius[AU] * km/[AU] ) / km/s
cme_t1n = anytim(anytim(t_sol)+cme_tn,/ccs)           ; Starting_time + travel_time
; and the velocity errors:
cme_tp = (rad *  150e6) / (cme_vel+e_vel)   ; (radius[AU] * km/[AU] ) / km/s
cme_t1p = anytim(anytim(t_sol)+cme_tp,/ccs)           ; Starting_time + travel_time


  ; and plot it
  ;xyouts,0,0,t_sol
  ;xyouts,inter[0],inter[1],anytim(cme_t1,/YOHKOH)

;===================================================================
;================ Calculate position of planet at the time of impact
jd_struct = anytim2jd(cme_t1)
jd = jd_struct.int + jd_struct.frac
helio, jd, planet.n, planet_t1_rad, planet_t1_lon, planet_t1_lat
year = (strsplit(anytim(cme_t1,/ecs),'/',/extract))[0]
long_asc_node = 74+(22.+((year-1900)*.84))/60.
planet_t1_lon = planet_t1_lon - long_asc_node 
polrec,planet_t1_rad,planet_t1_lon,planet_t1_x,planet_t1_y,/degrees
  ; and plot it
  ;set_line_color
  ;plots,planet_t1_x,planet_t1_y,psym=4,color=3
hitpos=planet.start
hitpos.date = anytim(jd2ecs(jd),/ccs)
hitpos.radio = planet_t1_rad
hitpos.lon = planet_t1_lon
hitpos.lat = planet_t1_lat
hitpos.orbit_x = planet_t1_x
hitpos.orbit_y = planet_t1_y

inputs = {st_time:anytim(t_sol,/ccs), st_long:x_sol[0], st_long_hci:cme_lon,width:dlong, cme_vel:cme_vel, cme_vel_e: e_vel}
minmaxt = {t_min:cme_t1p, t_max:cme_t1n}

planet_out = {n:planet.n,start:planet.start,orbit:planet.orbit,param:planet.param,hitpos:hitpos,hitormiss:0b,inputs:inputs,minmax_t:minmaxt}
cme_val = [cme_t/(3600.*24.),rad] ; [days,au]
;===================================================================
;====================== Calculate whether it hits or miss the planet

planet_out.hitormiss=angleinrange(cme_lon,dlong,planet_t1_lon)

end
