@angleinrange.pro
@long_hgihg.pro
@planet_orbit.pro
pro ploting_sep,planets,range=range,file_out=file_out

rot_sun =  14.4 
vel_wind = planets[0].input.vel + [-planets[0].input.e_vel,planets[0].input.e_vel]
sw_lon = planets[0].input.long_hci
planets_colors=[9,7,5,3,6,2,4,10,9]
range=[-range,range]

;; Define solar wind spiral
v_plot = (vel_wind[1] eq vel_wind[0])?vel_wind[0]:findgen(fix(vel_wind[1]-vel_wind[0]))+vel_wind[0]
v_au_plot =  ( v_plot / 150e6 ) * 24. * 60. * 60.
theta_sp = -findgen( 360 * 6. )                  ;
r_plot = -( v_au_plot / rot_sun ) # theta_sp ; 2 dimension [(vel-e,vel+e),radius]
theta_spiral = theta_sp + sw_lon

;; Plot properties
set_plot,'z'
loadct,0,/silent
set_line_color
Device, Set_Resolution=[2400, 2400]
;window,15,xsize=600, ysize=600
!p.background = 255
position=[0.1,0.1,0.9,0.9]
xsol=[0,0]
ysol=[0,0]
ff=1
Cs=1.5*4
syms = 7

;; Plot background
set_line_color
plot,xsol,ysol,psym=3,xrange=range,yrange=range,xstyle=5,ystyle=5,position=position
for i=0,n_elements(v_plot)-1 do begin
   polrec,r_plot[i,*],theta_spiral,spir_x,spir_y,/degrees
   oplot,spir_x,spir_y,color=150 ;,thick=1
endfor
circle_sym, thick = 2, /fill

;; Plot planets (and orbit)
;;; depending of range => plot the planets with smaller radius
in_range = (range[1] lt 3)?where(planets.start.radio lt range[1],n_inr):where((planets.start.radio lt range[1]) and (planets.start.radio gt 3),n_inr)

for i=0,n_inr-1 do begin
      pp=plot_orbit(planets[in_range[i]],/orbit,/over,color=200,thick=5)
      plots,planets[in_range[i]].start.orbit_x,planets[in_range[i]].start.orbit_y,psym=8,color=planets_colors[planets[in_range[i]].n-1],symsize=syms
endfor


;; and the line connecting with those.
;; if hit
hit = where(planets[in_range].hit.hitormiss eq 1,n_hit)
for i=n_hit-1,0,-1 do begin
   vel_n_w =   planets[in_range[hit[i]]].hit.swvel * (24. * 60. * 60.) / 150e6
   new_r_spiral = -( vel_n_w / rot_sun) * theta_sp
   lab_dist = where(new_r_spiral le planets[in_range[hit[i]]].start.radio)
   polrec,new_r_spiral[lab_dist],theta_spiral[lab_dist],spir_x,spir_y,/degrees
   oplot,spir_x,spir_y,color=planets_colors[planets[in_range[hit[i]]].n-1],thick=4
endfor
;plot the sun!!!
 plots, [ 0 , 0 ], [ 0, 0 ], psym = 8, color = 2, symsize = syms+1

;Legend of planets
plots,0.1,0.1,/normal,psym = 8, color = 2, symsize = syms
xyouts, 0.13,0.09, 'Sun',color=0,/normal,Font=ff, Charsize=cs
if range[1] lt 5 then begin
   plots,0.1,0.05,/normal,psym = 8, color = planets_colors[0], symsize = syms
   xyouts, 0.13,0.04, 'Mercury',color=0,/normal,Font=ff, Charsize=cs
   plots,0.3,0.05,/normal,psym = 8, color = planets_colors[1], symsize = syms
   xyouts, 0.33,0.04, 'Venus',color=0,/normal,Font=ff, Charsize=cs
   plots,0.5,0.05,/normal,psym = 8, color = planets_colors[2], symsize = syms
   xyouts, 0.53,0.04, 'Earth',color=0,/normal,Font=ff, Charsize=cs
   plots,0.7,0.05,/normal,psym = 8, color = planets_colors[3], symsize = syms
   xyouts, 0.73,0.04, 'Mars',color=0,/normal,Font=ff, Charsize=cs
endif else begin
   plots,0.1,0.05,/normal,psym = 8, color = planets_colors[4], symsize = syms
   xyouts, 0.13,0.04, 'Jupiter',color=0,/normal,Font=ff, Charsize=cs
   plots,0.3,0.05,/normal,psym = 8, color = planets_colors[5], symsize = syms
   xyouts, 0.33,0.04, 'Saturn',color=0,/normal,Font=ff, Charsize=cs
   plots,0.5,0.05,/normal,psym = 8, color = planets_colors[6], symsize = syms
   xyouts, 0.53,0.04, 'Uranus',color=0,/normal,Font=ff, Charsize=cs
   plots,0.7,0.05,/normal,psym = 8, color = planets_colors[7], symsize = syms
   xyouts, 0.73,0.04, 'Neptune',color=0,/normal,Font=ff, Charsize=cs
   plots,0.85,0.05,/normal,psym = 8, color = planets_colors[8], symsize = syms
   xyouts, 0.88,0.04, 'Pluto',color=0,/normal,Font=ff, Charsize=cs
endelse
background = TVREAD(TRUE=3)

a = rebin(transpose(background,[2,0,1]),3,600,600)
write_png,file_out+'.png',a
set_plot,'x'

end

pro tables_sep,planets,file_out=file_out,votable=votable
;  always csv output!
planet_name = ['MERCURY','VENUS','EARTH','MARS','JUPITER','SATURN','URANUS','NEPTUNE','PLUTO']

openw,lun,file_out+'.csv',/get_lun
printf,lun,"time_start,long_hg,long_hci,v,v_err,target_obj,r_hci,HitOrMiss,v_estimated,ETA,Dt[s]"
start_str = planets[0].input.date + ',' + $
            string(planets[0].input.long_hg,format='(F6.2)') +',' + $
            string(planets[0].input.long_hci,format='(F6.2)') +',' + $
            string(planets[0].input.vel,format='(F7.2)') +','+$
            string(planets[0].input.e_vel,format='(F7.2)')
for i = 0,8  do begin
   dt=(planets[i].hit.eta eq 0)?'':string(planets[i].hit.eta,format='(I7)')
   swvel=(planets[i].hit.swvel eq 0)?'':string(planets[i].hit.swvel,format='(F7.2)') 
   rest_str = planet_name[planets[i].n-1] + ',' + $ ; Planet
              string(planets[i].start.radio,format='(F7.3)') +',' +  $ ; distance
              string(planets[i].hit.hitormiss,format='(I1)') +',' +  $ ; HitOrMiss
              swvel+',' + $                                            ; velocity stimated
              planets[i].hit.date +','+$                               ; time of arrival
              dt                                                       ; dt in seconds.
   printf,lun,start_str+','+rest_str
endfor
close,/all


;  votable optative (stilts)
;/votable => ext = '.votable'
if keyword_set(votable) then begin
   stilts_command = './stilts tcopy '+file_out+'.csv ifmt=csv '+file_out+'.votable ofmt=votable'
   spawn,stilts_command
endif
end
pro web_sep,planets,file_out=file_out
planet_name = ['MERCURY','VENUS','EARTH','MARS','JUPITER','SATURN','URANUS','NEPTUNE','PLUTO']

file_input = file_out+'_input_'
file_output = file_out+'_output_'
file_cxs = file_out+'_cxs_'

openw,lun,file_input,/get_lun
  printf,lun,"<li> Start Time <div class='input'>"+planets[0].input.date+"</div></li>"
  printf,lun,"<li> Longitude <div class='input'>"+string(planets[0].input.long_hg,format='(F6.2)')+"</div></li>"
  printf,lun,"<li> SolarWind speed <div class='input'>"+string(planets[0].input.vel,format='(F7.2)') +" &plusmn; "+string(planets[0].input.e_vel,format='(F7.2)')+"</div></li>"
  printf,lun,"<li> <a href='http://cagnode58.cs.tcd.ie:8080/PropagationModelGUI/'><button type='button'>Reset</button></a></div></li>"
  printf,lun,"</ul> </div>  <!-- input values -->"
;  printf,lun,"</div><!-- input box -->"
close,/all

openw,lun,file_output,/get_lun
  printf,lun,"	<div class='Result'> <!-- result box -->"
  hits = where(planets.hit.hitormiss eq 1,nhits)
  if nhits eq 0 then begin
     printf,lun," <ul> <li> No Planet is hit </li></ul>"
  endif else begin
     printf,lun," <ul> <li> Output </li></ul>" 
     printf,lun,"    <table>" 
     printf,lun,"     <tr> <th> Planet </th> <th> Speed</th> <th> ETA </th> <th> Dt(seconds) </th></tr>"
     for i=0,nhits-1 do begin
        t_min = strsplit(planets[hits[i]].hit.date,"T",/extract)
        printf,lun,"     <tr> <td>"+planet_name[planets[hits[i]].n-1]+"</td><td>"+$
                                   string(planets[hits[i]].hit.swvel,format='(F7.2)')+"</td><td>"+$
                                   t_min[0]+"<br>"+t_min[1]+"</td><td align='center'>"+$
                                   string(planets[hits[i]].hit.eta,format='(I7)')+$
                   "</td></tr>"
     endfor
     printf,lun,"    </table>" 
     printf,lun,"<div class='download'><a href='./sep_pm.votable'><button type='button'>Download VOTable</button></a></div>"
  endelse
  printf,lun,"   </div> <!-- result box -->"
close,/all

openw,lun,file_cxs ,/get_lun
  printf,lun,"		<div class='links'> <!-- links box -->"
  printf,lun,"	  <ul>"
  date=strsplit(anytim(planets[0].input.date,/ecs,/date),'/',/extract)
  date0=strsplit(anytim(anytim(planets[0].input.date)-(24*3600.),/ecs,/date),'/',/extract)
  date1=strsplit(anytim(anytim(planets[0].input.date)+(24*3600.),/ecs,/date),'/',/extract)
  link_goes = "http://helio-vo.eu/services/interfaces/helio-cxs_soap2.php?y_from="+date0[0]+"&mo_from="+date0[1]+"&d_from="+date0[2]+"&h_from=00&mi_from=00&s_from=00&y_to="+date1[0]+"&mo_to="+date1[1]+"&d_to="+date1[2]+"&h_to=23&mi_to=59&s_to=59&cxs_process=goesplotter&format=html"
  printf,lun,"      <li> <a href='"+link_goes+"'> GOES plotter</a></li>"
  link_flares = "http://helio-vo.eu/services/interfaces/helio-cxs_soap2.php?y_from="+date0[0]+"&mo_from="+date0[1]+"&d_from="+date0[2]+"&h_from=20&mi_from=00&s_from=00&y_to="+date1[0]+"&mo_to="+date1[1]+"&d_to="+date1[2]+"&h_to=23&mi_to=59&s_to=59&cxs_process=flareplotter&format=html"
  printf,lun,"      <li> <a href='"+link_flares+"'> Flare plotter</a></li>"
  
  sm_link = "http://solarmonitor.org/index.php?date="+date[0]+date[1]+date[2]
  printf,lun,"      <li> <a href='"+sm_link+"'> Solar Monitor for "+anytim(planets[0].input.date,/vms,/date)+"</a></li>"

  sw_link = "http://spaceweather.com/archive.php?view=1&day="+date[2]+"&month="+date[1]+"&year="+date[0]
  printf,lun,"      <li> <a href='"+sw_link+"'> Space Weather for "+anytim(planets[0].input.date,/vms,/date)+"</a></li>"

  printf,lun," </ul>"
close,/all

;spawn cat header .... footer > file_out
join_all = 'cat sep_index_header.html '+file_input+' '+file_output+' '+file_cxs +' sep_index_footer.html > '+ file_out
spawn,join_all

;spawn delete midfiles
delete_midfiles = 'rm '+file_input+' '+file_output+' '+file_cxs 
spawn,delete_midfiles
end
pro prop_sep,t0=t0,x0=x0,vel=vel,e_vel=e_vel,PATH_OUT=path_out

if ~keyword_set(path_out) then path_out='/tmp/'
if ~keyword_set(t0) then t0 = anytim(systim(),/ccs) else t0=anytim(t0,/ccs)
if ~keyword_set(x0) then x0=[0]; lon-lat HG
if ~keyword_set(vel) then vel=400 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s
;if ~keyword_set(file_out) then file_out = '/tmp/prop_'+string(strcompress(t0,/remove_all))

part_speed=0.9 ;c times! relativistic particles

;; 1 Calculate the spiral with the input values.
vel_wind=abs(vel)+[-e_vel,+e_vel]
vel_wind_au = ( vel_wind / 150e6 ) * 24. * 60. * 60. ; AU per day
rot_sun =  14.4                                      ; rotation rate of the Sun in degrees per day
theta_sp = -findgen( 360 * 6. )                  ;
r_spiral = -( vel_wind_au / rot_sun ) # theta_sp ; 2 dimension [(vel-e,vel+e),radius]


;; --- change long in hg to hgi and obtain new angles in hgi
;;     coordinate system.
sw_lon = long_hgihg(x0[0],/hg,date=t0,long_asc_node=long_asc_node) ;degrees
theta_spiral = theta_sp + sw_lon
;theta_spiral = (theta_spiral+(360*6)) mod 360

;; 2 Calculate planet positions. 
jd_struct = anytim2jd(t0)
jd = jd_struct.int + jd_struct.frac


;; ---- Calculating values for each planet
for i=1,9 do begin
   ;; ---- defining structures
   start = {date:'',radio:0.,lon:0.,lat:0.,orbit_x:0.,orbit_y:0.}
   hit = {hitormiss:0b,eta:0.,date:'',swvel:0.,partvel:0.,dist:0.}
   input={date:anytim(t0,/ccs),long_hg:x0,long_hci:sw_lon,vel:vel,e_vel:e_vel}
   planet = {n:0,name:'',start:start,hit:hit,input:input}

   planet.n = i
   ;; ---- Position
   helio, jd, i, hel_rad, hel_lon, hel_lat
   polrec,hel_rad,hel_lon - long_asc_node,dx,dy,/degrees
   planet.start.date = t0
   planet.start.radio = hel_rad
   planet.start.lon = (hel_lon - long_asc_node + 360) mod 360
   planet.start.lat = hel_lat
   planet.start.orbit_x = dx
   planet.start.orbit_y = dy

   ;; ---- HitOrMiss?
   for j=0,1 do begin
      rad_hit = abs(r_spiral[j,*] - hel_rad)
     ; stop
      orbit_cross = where(rad_hit eq min(rad_hit),nrad)
      if nrad gt 0 then begin
         pos_ang = (j eq 0)?[theta_spiral[orbit_cross]]:[pos_ang,theta_spiral[orbit_cross]]
      endif
   endfor

   if n_elements(pos_ang) eq 2 then begin
;      pos_ang = pos_ang mod 360
;      if ((pos_ang[0] lt 0) or (pos_ang[1] lt 0)) then pos_ang = pos_ang + 360
;      hitormiss = angleinrange(mean(pos_ang),max(pos_ang)-min(pos_ang),planet.start.lon)
      hitormiss = angleinrange2(planet.start.lon,pos_ang)
      ; TODO: Fix problem with  far orbits and angles!!
      ; example Neptune! with this input 2011-10-19T23:11:05.000, 50.00,  0.13, 500.00,
      print, i,' ',pos_ang,' ',planet.start.lon,' ',sw_lon,' ',abs(planet.start.lon-sw_lon),' ',hitormiss
      if hitormiss eq 1 then begin
         vel_n_w = 0;(planet.start.radio*rot_sun)/(abs(planet.start.lon-sw_lon)+(mm*360.))
         mm = 0.
         while not ((vel_n_w ge vel_wind_au[0]) and (vel_n_w le vel_wind_au[1])) do begin
            vel_n_w = abs(-(planet.start.radio*rot_sun)/(abs(planet.start.lon-sw_lon)-(mm*360.)))
            mm = mm + 1.
            if mm gt 100 then goto,break_while
            print, i, mm, vel_n_w, vel_wind_au[0],vel_wind_au[1]
         endwhile
         planet.hit.swvel = vel_n_w * 150e6 /(24. * 60. * 60.)   ; km/s
         new_r_spiral = -( vel_n_w / rot_sun) * theta_sp
         lab_dist = where(new_r_spiral le planet.start.radio)
         dist_SEspiral = 0
         for dd=0,n_elements(lab_dist)-2 do dist_SEspiral=(r_spiral[lab_dist[dd+1]]-r_spiral[lab_dist[dd]])+dist_SEspiral
         planet.hit.partvel = part_speed
         planet.hit.dist = dist_SEspiral
         planet.hit.eta = dist_SEspiral*500/part_speed  ; (1 AU = 150e6 km)/(c = 3e5 km/s) = 500 s.
         planet.hit.date = anytim(anytim(t0)+planet.hit.eta,/ccs)
         print,planet.n,' ',planet.hit.eta,' ',planet.hit.date,' ',planet.hit.swvel
      endif
      planet.hit.hitormiss=hitormiss
      print,'while not broken'
      break_while: 
   endif
   planet_all = (i eq 1)?planet:[planet_all,planet]
endfor

;TODO: add paths to the outputs
ploting_sep,planet_all,range=2.5,file_out=path_out+'sep_pm_inner'
ploting_sep,planet_all,range=46.5,file_out=path_out+'sep_pm_outer'
tables_sep,planet_all,file_out=path_out+'sep_pm',/votable
web_sep,planet_all,file_out=path_out+'index.html'

end
