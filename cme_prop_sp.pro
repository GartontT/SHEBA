pro cme_prop_sp,planetn=planetn,x_sol=x_sol,t_sol=t_sol,cme_vel=cme_vel,dlong=dlong,planet_out=planet_out,cme_val=cme_val
if ~keyword_set(planetn) then planetn = 3
if ~keyword_set(t_sol) then t_sol = systim()
if ~keyword_set(cme_vel) then cme_vel=800 ;km/s
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
cme_t1 = anytim(anytim(t_sol)+cme_t,/ecs)           ; Starting_time + travel_time
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
hitpos.date = jd2ecs(jd)
hitpos.radio = planet_t1_rad
hitpos.lon = planet_t1_lon
hitpos.lat = planet_t1_lat
hitpos.orbit_x = planet_t1_x
hitpos.orbit_y = planet_t1_y
planet_out = {n:planet.n,start:planet.start,orbit:planet.orbit,param:planet.param,hitpos:hitpos,hitormiss:0b}
cme_val = [cme_t/(3600.*24.),rad] ; [days,au]
;===================================================================
;====================== Calculate whether it hits or miss the planet
if cme_lon-dlong/2 gt 180 then cme_lon = cme_lon-360.
if planet_t1_lon gt 180 then planet_t1_lon = planet_t1_lon-360.
if (planet_t1_lon le cme_lon+dlong/2) and (planet_t1_lon ge cme_lon-dlong/2) then planet_out.hitormiss = 1b else  planet_out.hitormiss = 0b
  ; and plot it
  ;recpol,inter[0],inter[1],rad,ang,/degrees
  ;polrec,rad,ang-dlong/2,xx,yy,/degrees
  ;oplot,[0,xx],[0,yy],linestyle=2
  ;polrec,rad,ang+dlong/2,xx,yy,/degrees
  ;oplot,[0,xx],[0,yy],linestyle=2

end
;; stop

;; polrec,2*max(planet.orbit.radio),cme_lon,xf,yf,/degrees
;; m = yf/xf
;; A = ellip[0]*cos(ellip[4])*m
;; Ap= ellip[0]*sin(ellip[4])
;; B = ellip[1]*sin(ellip[4])*m
;; Bp= ellip[1]*cos(ellip[4])
;; inter_ang0 = atan((A-ap),(b-bp))  ;this is valid when Yc = y0
;; ; ie, the CME starts on the sun which is the center of the ellipse

;; plot,planet.orbit.orbit_x,planet.orbit.orbit_y,psym=4
;; oplot,[0,xf],[0,yf]
;; inter_ang = [0,!pi] + inter_ang0 - ellip[4]
;; diff=min(abs(abs(cme_lon*!pi/180.)-abs(inter_ang)),which)
;; inter_angHGI=inter_ang[which]

;; inter_ang=(which eq 1)?!pi+inter_ang0:inter_ang0

;; print,inter_ang,' radians = ', inter_ang*180./!pi,' degrees'
;; print,inter_ang+planet.param[4],' radians = ', (inter_ang+planet.param[4])*180./!pi,' degrees'

;; end
;; stop


;; planet_pos={name:'earth',numb:3,time:t_sol,lat:0.,lon:0.,rad:0.}; 
;;  jd_struct = anytim2jd(t_sol)
;;  jd = jd_struct.int + jd_struct.frac
;;  helio, jd, planet_pos.numb, hel_rad, hel_lon, hel_lat
;;  planet_pos.lat = hel_lat
;;  planet_pos.lon = hel_lon
;;  planet_pos.rad = hel_rad * 150e6
 

;; ;1.- time to get at radius of planet at t_sol:
;; cme_t = planet_pos.rad / cme_vel
;; cme_t1 = anytim(anytim(t_sol)+cme_t,/ecs)
;; ;2.- Update planet pos for t1
;; planet_post1=planet_pos
;;  jd_struct = anytim2jd(cme_t1)
;;  jd = jd_struct.int + jd_struct.frac
;;  helio, jd, planet_pos.numb, hel_rad, hel_lon, hel_lat
;;  planet_post1.lat = hel_lat
;;  planet_post1.lon = hel_lon
;;  planet_post1.rad = hel_rad * 150e6
;;  planet_post1.time = cme_t1

;; ;3.- Is planet in cme range? long_cme + dlong?
;; print,((abs(planet_pos.rad - planet_post1.rad) lt 1e5) and (abs(planet_post1.lon - x_sol[0]) lt dlong))?'Hit':'Missed'

;; ;plot,[0, ],[0,]

;; stop
;; end
