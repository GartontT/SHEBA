pro CME_prop,x_sol=x_sol,t_sol=t_sol,cme_vel=cme_vel,dlong=dlong
if ~keyword_set(t_sol) then t_sol = systim()
if ~keyword_set(cme_vel) then cme_vel=800 ;km/s
if ~keyword_set(x_sol) then x_sol=[0,0]; lon-lat HGI
if ~keyword_set(dlong) then dlong=2 ; width in deg

cme_lon = 25 ;degrees
ellip = planet_orbit(t_sol,3,planet=earth)  

polrec,2*max(earth.orbit.radio),cme_lon,xf,yf,/degrees
m = yf/xf
A = ellip[0]*cos(ellip[4])*m
Ap= ellip[0]*sin(ellip[4])
B = ellip[1]*sin(ellip[4])*m
Bp= ellip[1]*cos(ellip[4])
inter_ang0 = atan((A-ap),(b-bp))  ;this is valid when Yc = y0
; ie, the CME starts on the sun which is the center of the ellipse

plot,earth.orbit.orbit_x,earth.orbit.orbit_y,psym=4
oplot,[0,xf],[0,yf]
inter_ang = [0,!pi] + inter_ang0 - ellip[4]
diff=min(abs(abs(cme_lon*!pi/180.)-abs(inter_ang)),which)
inter_angHGI=inter_ang[which]

inter_ang=(which eq 1)?!pi+inter_ang0:inter_ang0

print,inter_ang,' radians = ', inter_ang*180./!pi,' degrees'
print,inter_ang+earth.param[4],' radians = ', (inter_ang+earth.param[4])*180./!pi,' degrees'

stop


planet_pos={name:'earth',numb:3,time:t_sol,lat:0.,lon:0.,rad:0.}; 
 jd_struct = anytim2jd(t_sol)
 jd = jd_struct.int + jd_struct.frac
 helio, jd, planet_pos.numb, hel_rad, hel_lon, hel_lat
 planet_pos.lat = hel_lat
 planet_pos.lon = hel_lon
 planet_pos.rad = hel_rad * 150e6
 

;1.- time to get at radius of planet at t_sol:
cme_t = planet_pos.rad / cme_vel
cme_t1 = anytim(anytim(t_sol)+cme_t,/ecs)
;2.- Update planet pos for t1
planet_post1=planet_pos
 jd_struct = anytim2jd(cme_t1)
 jd = jd_struct.int + jd_struct.frac
 helio, jd, planet_pos.numb, hel_rad, hel_lon, hel_lat
 planet_post1.lat = hel_lat
 planet_post1.lon = hel_lon
 planet_post1.rad = hel_rad * 150e6
 planet_post1.time = cme_t1

;3.- Is planet in cme range? long_cme + dlong?
print,((abs(planet_pos.rad - planet_post1.rad) lt 1e5) and (abs(planet_post1.lon - x_sol[0]) lt dlong))?'Hit':'Missed'

;plot,[0, ],[0,]

stop
end
