pro cme_prop_os,object=object,t_object=t_object,cme_vel=cme_vel,cme_lon=cme_lon,t_sun=t_sun
if ~keyword_set(object) then object='EARTH' else object=strupcase(object)
if ~keyword_set(t_object) then t_object = systim()
if ~keyword_set(cme_vel) then cme_vel=800 ;km/s

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

obj_rad = query_res[lab_closest].r_hci
long_hci= query_res[lab_closest].long_hci

;===================================================================
;=============== Calculate the time it takes to the CME to get there
cme_t = (obj_rad *  150e6) / cme_vel   ; (radius[AU] * km/[AU] ) / km/s
t_sun = anytim(anytim(t_object)-cme_t,/CCSDS) ; Starting_time + travel_time
  ; and plot it
  ;xyouts,0,0,t_sol
  ;xyouts,inter[0],inter[1],anytim(cme_t1,/YOHKOH)

;===================================================================
;=============== Calculate the position on the sun
cme_lon = long_hgihg(long_hci,/ihg,date=t_sun) ;degrees

print,' CME lon '+string(cme_lon)
print,' Time    '+anytim(t_sun,/YOHKOH)
end_program:
end
