pro sep_prop_os,object=object,t_object=t_object,sw_vel=sw_vel,beta=beta,sep_lon=sep_lon,t_sun=t_sun
if ~keyword_set(object) then object='EARTH' else object=strupcase(object)
if ~keyword_set(t_object) then t_object = systim()
if ~keyword_set(sw_vel) then sw_vel=400 ;km/s

time_range=anytim(anytim(t_object)+([-1,1]*(3600*24.)),/CCSDS)
;===================================================================
;==================== Find object position.
query = "http://msslkz.mssl.ucl.ac.uk/stilts/task/sqlclient?"+$
        "db=jdbc:mysql://msslkz.mssl.ucl.ac.uk/helio_ils&"+$
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
t_object = anytim(query_res[lab_closest].time,/CCSDS)

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
foot_point_obj = abs(spiral[ll])

spiral_obj = spiral + long_hci + foot_point_obj
sep_lon_hci = spiral_obj[0]
;sep_lon_hci = posang(long_hci - (obj_rad * rot_sun/vel_wind_au))

sep_lon = long_hgihg(sep_lon_hci,/ihg,date=t_object)
;TODO It's this t_object the real object time? or the closest?
;should be the input one, as it's when the event was
;observed. Positions may be different, but not much.

points2object = where(r_spiral le obj_rad,npoints)

;===================================================================
;=============== Calculate the time it takes to the SEP
if npoints ne 0 then begin
   dist = arcdist(r_spiral[points2object],spiral[points2object]) ; distance in AU
   delta_time = dist * 500 / beta     
   t_sun = anytim(anytim(t_object)-delta_time,/CCSDS)
endif else begin
   t_sun = 'NULL'
endelse
end_program:
end
