;==================================================================
;Copyright 2011, 2012  David Pérez-Suárez (TCD-HELIO)
;===================GNU license====================================
;This file is part of SHEBA.
;
;    SHEBA is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    SHEBA is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with SHEBA.  If not, see <http://www.gnu.org/licenses/>.
;==================================================================
function plot_sc,spacecraft,over=over,orbit=orbit,points=points,zero=zero,coord=coord,ninety=ninety,_extra=_extra

; check other variables

plot_command =(~keyword_set(over))?'plot,xrange=xrange,yrange=yrange':'oplot'

if keyword_set(orbit) then begin
;plot ellipse
   a = execute(plot_command+',spacecraft.orbit_steps.orbit_x,spacecraft.orbit_steps.orbit_y,_extra=_extra')
   plot_command = 'oplot'
endif
if keyword_set(points) then begin
   xm=spacecraft.orbit_steps.orbit_x
   ym=spacecraft.orbit_steps.orbit_y
   a=execute(plot_command+',xm,ym,_extra=_extra')
   if keyword_set(coord) then for i=0,n_elements(xm)-1 do xyouts,xm[i]+0.01,ym[i]+0.01,spacecraft.orbit_steps.lon[i]
   plot_command = 'oplot'
endif
;


return,1
end

function spacecraft_path,date,drange=drange
;-
;  spacecraft_orbit
;+


spacecrafts=['Ulysses','StereoA','StereoB','Messenger',$
             'Voyager1','Voyager2','Galileo','Cassini',$
             'NewHorizons','Rosetta','Dawn']
days = (n_elements(drange) eq 0)?30:drange
time_range=anytim(anytim(date)+([0,1]*(3600*24.*days)),/CCSDS)

inputs = {st_time:'', st_long:0., st_long_hci:0.,width:0.,$
          cme_vel:0., cme_vel_e: 0., $
          sw_vel:0., sw_vel_e: 0., $
          beta:0.}
minmaxt = {t_min:'', t_max:''}

query = "http://msslkz.mssl.ucl.ac.uk/stilts/task/sqlclient?"+$
        "db=jdbc:mysql://msslkz.mssl.ucl.ac.uk/helio_ils&"+$
        "user=helio_guest&sql=select target_obj,time,julian_int,"+$
        "r_hci, long_hci, lat_hci, long_carr from trajectories where "+$
        "time between '"+time_range[0]+"' and '"+time_range[1]+$
        "' and (" +$
        STRJOIN(string(strupcase(spacecrafts),format='(("target_obj=","''",A,"''",:," OR "))'))+$
        ") order by target_obj &ofmt=vot"

query_res = ssw_hio_query(query,/conv)

if data_chk(query_res,/type) ne 8 then return,-1

k=0
max_elements = max(str_hist(query_res.target_obj))

for i = 0,n_elements(spacecrafts)-1 do begin
   pos = where(query_res.target_obj eq strupcase(spacecrafts[i]),npos)
   if npos gt 0 then begin
      dates = strarr(max_elements)
      radio = fltarr(max_elements) * !VALUES.F_NAN  
      long  = radio
      lat   = radio
      k++
      ;sort the results by time
      order = sort(query_res[pos].julian_int)
      dates[0:n_elements(order)-1] = anytim(query_res[pos[order]].time,/CCSDS)
      radio[0:n_elements(order)-1] = query_res[pos[order]].r_hci
      long[0:n_elements(order)-1]  = query_res[pos[order]].long_hci
      lat [0:n_elements(order)-1]  = query_res[pos[order]].lat_hci
      polrec,radio,long,dx,dy,/degrees
      orbit_steps = {date: dates, radio: radio, lon: long,$
                     lat: lat, orbit_x: dx, orbit_y: dy}
      time_diff = abs(query_res[pos[order]].julian_int-(anytim2jd(date)).int)
      st_time = min(time_diff,st_pos)
      start_pos = {date: dates[st_pos], radio: radio[st_pos], lon: long[st_pos],$
                   lat: lat[st_pos], orbit_x: dx[st_pos], orbit_y: dy[st_pos]}
      pos_thit = {date: dates[st_pos], radio: radio[st_pos], lon: long[st_pos],$
                   lat: lat[st_pos], orbit_x: dx[st_pos], orbit_y: dy[st_pos], $
                   sw_vel:0. , sw_vel_au:0., spiral_angle:0., spiral_dist: 0., delta_time: 0.}
      spacecraft = {name:spacecrafts[i],pos_t0:start_pos,orbit_steps:orbit_steps,$
                    hitOrmiss:0b,pos_thit:pos_thit,input:inputs,minmaxt:minmaxt}
      all_spacecrafts = (k eq 1)?spacecraft:[all_spacecrafts,spacecraft]
   endif
endfor

return,all_spacecrafts
end

