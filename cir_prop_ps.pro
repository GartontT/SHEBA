pro cir_prop_ps,planetn=planetn,t_planet=t_planet,sw_vel=sw_vel,cir_lon=cir_lon,t_sun=t_sun
if ~keyword_set(planetn) then planetn = 3
if ~keyword_set(t_planet) then t_planet = systim()
if ~keyword_set(sw_vel) then sw_vel=600 ;km/s

;===================================================================
;==================== Find planet position                      ;;***  find whether a ihg coord are input (sc)
jd_struct = anytim2jd(t_planet)
jd = jd_struct.int + jd_struct.frac
helio, jd, planetn, planet_t1_rad, planet_t1_lon, planet_t1_lat
year = (strsplit(anytim(t_planet,/ecs),'/',/extract))[0]
long_asc_node = 74+(22.+((year-1900)*.84))/60.
planet_t1_lon = planet_t1_lon - long_asc_node 


;===================================================================
;=============== Calculate the origin of the SEP event
rot_sun = 14.4
vel_wind = sw_vel
vel_wind_au = ( vel_wind / 150e6 ) * 24. * 60. * 60.


spiral = -findgen(360 * 6.)
r_spiral = -(vel_wind_au/rot_sun) * spiral

dumb = min(abs(r_spiral - planet_t1_rad),ll)
foot_point_planet = abs(spiral[ll])

spiral_planet = spiral + planet_t1_lon + foot_point_planet
cir_lon_hci = spiral_planet[0]
;sep_lon_hci = posang(planet_t1_lon - (planet_t1_rad * rot_sun/vel_wind_au))

cir_lon = long_hgihg(cir_lon_hci,/ihg,date=t_planet)
print,cir_lon
t_sun = t_planet
  
end
