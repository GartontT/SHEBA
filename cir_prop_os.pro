pro cir_prop_os,object=object,t_object=t_object,sw_vel=sw_vel,cir_lon=cir_lon,t_sun=t_sun
if ~keyword_set(object) then object='EARTH' else object=strupcase(object)
if ~keyword_set(t_object) then t_object = systim()
if ~keyword_set(sw_vel) then sw_vel=400 ;km/s

time_range=anytim(anytim(t_object)+([-1,1]*(3600*24.)),/CCSDS)
;===================================================================
;==================== Find object position.
query = "http://msslxv.mssl.ucl.ac.uk:8080/stilts/task/sqlclient?"+$
        "db=jdbc:mysql://msslxt.mssl.ucl.ac.uk/helio_ils&"+$
        "user=helio_guest&sql=select target_obj,time,julian_int,"+$
        "r_hci, long_hci, lat_hci, long_carr from trajectories where "+$
        "time between '"+time_range[0]+"' and '"+time_range[1]+$
        "' and (" +$
        STRJOIN(string(strupcase(object),format='(("target_obj=","''",A,"''",:," OR "))'))+$
        ") order by target_obj &ofmt=vot"

query_res = ssw_hio_query(query,/conv)

if data_chk(query_res,/type) ne 8 then goto,end_program

seconds = anytim(query_res.time)
closest = min(abs(seconds - anytim(t_object)),lab_closest)

t_object = query_res[lab_closest].time

obj_rad = query_res[lab_closest].r_hci
long_hci= query_res[lab_closest].long_hci


;===================================================================
;=============== Calculate the origin of the SEP event
rot_sun = 14.4
vel_wind = sw_vel
vel_wind_au = ( vel_wind / 150e6 ) * 24. * 60. * 60.


spiral = -findgen(360 * 6.)
r_spiral = -(vel_wind_au/rot_sun) * spiral

dumb = min(abs(r_spiral - obj_rad),ll)
foot_point_obj= abs(spiral[ll])

spiral_obj = spiral + long_hci + foot_point_obj
cir_lon_hci = spiral_obj[0]

cir_lon = long_hgihg(cir_lon_hci,/ihg,date=t_object)
print,cir_lon
t_sun = t_object

end_program:

end
