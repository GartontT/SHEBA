@./planet_orbit.pro
@./cme_prop_sp.pro

pro web_cme,planets,spacecraft,file_out=file_out
planet_name = ['MERCURY','VENUS','EARTH','MARS','JUPITER','SATURN','URANUS','NEPTUNE','PLUTO']

file_input = file_out+'_input_'
file_output = file_out+'_output_'
file_cxs = file_out+'_cxs_'

t0 = planets[0].input.st_time
openw,lun,file_input,/get_lun
  printf,lun,"<li> Start Time <div class='input'>"+planets[0].input.st_time+"</div></li>"
  printf,lun,"<li> Longitude <div class='input'>"+string(planets[0].input.st_long,format='(F6.2)')+"</div></li>"
  printf,lun,"<li> Width <div class='input'>"+string(planets[0].input.width,format='(F6.2)')+"</div></li>"
  printf,lun,"<li> CME speed <div class='input'>"+string(planets[0].input.cme_vel,format='(F7.2)') +" &plusmn; "+string(planets[0].input.cme_vel_e,format='(F7.2)')+"</div></li>"
  printf,lun,"<li> <a href='http://cagnode58.cs.tcd.ie:8080/PropagationModelGUI/'><button type='button'>Reset</button></a></div></li>"
  printf,lun,"</ul> </div>  <!-- input values -->"
;  printf,lun,"</div><!-- input box -->"
close,/all

openw,lun,file_output,/get_lun
  printf,lun,"	<div class='Result'> <!-- result box -->"
  hits = where(planets.hitormiss eq 1,nhits)

if data_chk(spacecraft,/type) eq 8 then  $
   schits = where(spacecraft.hitormiss eq 1,nschits) $
   else nschits = 0

  if nhits+nschits eq 0 then begin
     printf,lun," <ul> <li> No object is hit </li></ul>"
  endif else begin
     printf,lun," <ul> <li> Output </li></ul>" 
     printf,lun,"    <table>" 
     printf,lun,"     <tr> <th> object </th> <th> ETA min</th> <th> ETA max </th> <th> Dt min(days) </th><th> Dt max(days) </th></tr>"
     if nhits ne 0 then begin
        for i=0,nhits-1 do begin
           t_min = strsplit(planets[hits[i]].minmaxt.t_min,"T",/extract)
           t_max = strsplit(planets[hits[i]].minmaxt.t_max,"T",/extract)
           printf,lun,"     <tr> <td>"+strupcase(planets[hits[i]].name)+"</td><td>"+$
                  t_min[0]+"<br>"+t_min[1]+"</td><td>"+$
                  t_max[0]+"<br>"+t_max[1]+"</td><td align='center'>"+$
                  string((anytim(planets[hits[i]].minmaxt.t_min) - anytim(t0))/(3600.*24.),format='(F6.2)')+"</td><td>"+$
                  string((anytim(planets[hits[i]].minmaxt.t_max) - anytim(t0))/(3600.*24.),format='(F6.2)')+"</td><td>"+$
                  "</td></tr>"
        endfor
     endif
     if nschits ne 0 then begin
        for i = 0,nschits-1 do begin
           t_min = strsplit(spacecraft[schits[i]].minmaxt.t_min,"T",/extract)
           t_max = strsplit(spacecraft[schits[i]].minmaxt.t_max,"T",/extract)
           printf,lun,"     <tr> <td>"+spacecraft[schits[i]].name+"</td><td>"+$
                  t_min[0]+"<br>"+t_min[1]+"</td><td>"+$
                  t_max[0]+"<br>"+t_max[1]+"</td><td align='center'>"+$
                  string((anytim(spacecraft[schits[i]].minmaxt.t_min) - anytim(t0))/(3600.*24.),format='(F6.2)')+"</td><td>"+$
                  string((anytim(spacecraft[schits[i]].minmaxt.t_max) - anytim(t0))/(3600.*24.),format='(F6.2)')+"</td><td>"+$
                  "</td></tr>"
        endfor
     endif
     printf,lun,"    </table>" 
     printf,lun,"<div class='download'><a href='./cme_pm.votable'><button type='button'>Download VOTable</button></a></div>"
  endelse
  printf,lun,"   </div> <!-- result box -->"
close,/all

openw,lun,file_cxs ,/get_lun
  printf,lun,"		<div class='links'> <!-- links box -->"
  printf,lun,"	  <ul>"
  date=strsplit(anytim(t0,/ecs,/date),'/',/extract)
  date0=strsplit(anytim(anytim(t0)-(24*3600.),/ecs,/date),'/',/extract)
  date1=strsplit(anytim(anytim(t0)+(24*3600.),/ecs,/date),'/',/extract)
  link_goes = "http://helio-vo.eu/services/interfaces/helio-cxs_soap2.php?y_from="+date0[0]+"&mo_from="+date0[1]+"&d_from="+date0[2]+"&h_from=00&mi_from=00&s_from=00&y_to="+date1[0]+"&mo_to="+date1[1]+"&d_to="+date1[2]+"&h_to=23&mi_to=59&s_to=59&cxs_process=goesplotter&format=html"
  printf,lun,"      <li> <a href='"+link_goes+"'> GOES plotter</a></li>"
  link_flares = "http://helio-vo.eu/services/interfaces/helio-cxs_soap2.php?y_from="+date0[0]+"&mo_from="+date0[1]+"&d_from="+date0[2]+"&h_from=20&mi_from=00&s_from=00&y_to="+date1[0]+"&mo_to="+date1[1]+"&d_to="+date1[2]+"&h_to=23&mi_to=59&s_to=59&cxs_process=flareplotter&format=html"
  printf,lun,"      <li> <a href='"+link_flares+"'> Flare plotter</a></li>"
  
  sm_link = "http://solarmonitor.org/index.php?date="+date[0]+date[1]+date[2]
  printf,lun,"      <li> <a href='"+sm_link+"'> Solar Monitor for "+anytim(t0,/vms,/date)+"</a></li>"

  sw_link = "http://spaceweather.com/archive.php?view=1&day="+date[2]+"&month="+date[1]+"&year="+date[0]
  printf,lun,"      <li> <a href='"+sw_link+"'> Space Weather for "+anytim(t0,/vms,/date)+"</a></li>"

  printf,lun," </ul>"
close,/all

;spawn cat header .... footer > file_out
join_all = 'cat cme_index_header.html '+file_input+' '+file_output+' '+file_cxs +' cme_index_footer.html > '+ file_out
spawn,join_all

;spawn delete midfiles
delete_midfiles = 'rm '+file_input+' '+file_output+' '+file_cxs 
spawn,delete_midfiles
end



pro writing_prop_out,planet_all,spacecraft_all,path_out,x0,t0,width,vel,e_vel

file_out = path_out+'output'
;writing out the info
openw,lun,file_out+'.out',/get_lun
printf,lun,"#Starting parameters"
printf,lun,'Starting time: '+t0
printf,lun,'Starting longitude: '+string(x0,format='(F6.2)')
printf,lun,'Width: '+string(width,format='(F6.2)')
printf,lun,'Velocity: '+string(vel,format='(F7.2)')
for i=0,n_elements(planet_all)-1 do begin
   printf,lun,'------------------------------'
   printf,lun,'planet:'+string(planet_all[i].n,format='(I1)')
   printf,lun,'distance:'+string(planet_all[i].pos_t0.radio,format='(F7.3)')
   printf,lun,'hit:'+ string(planet_all[i].hitormiss,format='(I1)')
   t1_out = (planet_all[i].hitormiss eq 0)?'0':planet_all[i].pos_thit.date
   printf,lun,'eta:'+t1_out
endfor
if data_chk(spacecraft_all,/type) eq 8 then begin
   for i=0,n_elements(spacecraft_all)-1 do begin
      printf,lun,'------------------------------'
      printf,lun,'planet:'+spacecraft_all[i].name
      printf,lun,'distance:'+string(spacecraft_all[i].pos_t0.radio,format='(F7.3)')
      printf,lun,'hit:'+ string(spacecraft_all[i].hitormiss,format='(I1)')
      t1_out = (spacecraft_all[i].hitormiss eq 0)?'0':spacecraft_all[i].pos_thit.date
      printf,lun,'eta:'+t1_out
   endfor
endif
close,/all

file_out = path_out+'cme_pm'
openw,lun,file_out+'.csv',/get_lun
printf,lun,"time_start,long_hg,long_hci,long_width,v,v_err,target_obj,r_hci,HitOrMiss,ETA,ETA_min,ETA_max,Dt,Dt_min,Dt_max"
start_str = t0 + ',' + $
            string(x0,format='(F6.2)') +',' + $
            string(planet_all[0].input.st_long_hci,format='(F7.2)') +',' + $
            string(width,format='(F6.2)') +','+ $
            string(vel,format='(F7.2)') +','+$
            string(e_vel,format='(F7.2)')
for i = 0,n_elements(planet_all)-1  do begin
   t1_out = (planet_all[i].hitormiss eq 0)?'':planet_all[i].pos_thit.date
   t1_out_min = (t1_out eq '')?'':planet_all[i].minmaxt.t_min
   t1_out_max = (t1_out eq '')?'':planet_all[i].minmaxt.t_max
   dt1_out = (t1_out eq '')?'':string((anytim(planet_all[i].pos_thit.date) - anytim(t0))/(3600.*24.),format='(F7.2)')
   dt1_out_min = (t1_out eq '')?'':string((anytim(planet_all[i].minmaxt.t_min) - anytim(t0))/(3600.*24.),format='(F7.2)')
   dt1_out_max = (t1_out eq '')?'':string((anytim(planet_all[i].minmaxt.t_max) - anytim(t0))/(3600.*24.),format='(F7.2)')

   rest_str = strupcase(planet_all[i].name) + ',' + $ ; Planet
              string(planet_all[i].pos_t0.radio,format='(F7.3)') +',' +  $ ; distance
              string(planet_all[i].hitormiss,format='(I1)') +',' +  $ ; HitOrMiss
              t1_out +',' + $                                         ; time to reach earth
              t1_out_min +',' + $                                     ; min time
              t1_out_max   +',' + $                                   ; max time
              dt1_out +',' + $                                        ; days to reach earth
              dt1_out_min +',' + $                                    ; min number of days
              dt1_out_max                                             ; max number of days
   printf,lun,start_str+','+rest_str
endfor
if data_chk(spacecraft_all,/type) eq 8 then begin
   for i = 0,n_elements(spacecraft_all)-1  do begin
      t1_out = (spacecraft_all[i].hitormiss eq 0)?'':spacecraft_all[i].pos_thit.date
      t1_out_min = (t1_out eq '')?'':spacecraft_all[i].minmaxt.t_min
      t1_out_max = (t1_out eq '')?'':spacecraft_all[i].minmaxt.t_max
      dt1_out = (t1_out eq '')?'':string((anytim(spacecraft_all[i].pos_thit.date) - anytim(t0))/(3600.*24.),format='(F7.2)')
      dt1_out_min = (t1_out eq '')?'':string((anytim(spacecraft_all[i].minmaxt.t_min) - anytim(t0))/(3600.*24.),format='(F7.2)')
      dt1_out_max = (t1_out eq '')?'':string((anytim(spacecraft_all[i].minmaxt.t_max) - anytim(t0))/(3600.*24.),format='(F7.2)')

      rest_str = strupcase(spacecraft_all[i].name) + ',' + $ ; Spacecraft
                 string(spacecraft_all[i].pos_t0.radio,format='(F7.3)') +',' +  $ ; distance
                 string(spacecraft_all[i].hitormiss,format='(I1)') +',' +  $ ; HitOrMiss
                 t1_out +',' + $    ; time to reach earth
                 t1_out_min +',' + $ ; min time
                 t1_out_max   +',' + $ ; max time
                 dt1_out +',' + $      ; days to reach earth
                 dt1_out_min +',' + $  ; min number of days
                 dt1_out_max           ; max number of days
      printf,lun,start_str+','+rest_str
   endfor
endif
close,/all

stilts_command = './stilts tcopy '+file_out+'.csv ifmt=csv '+file_out+'.votable ofmt=votable'
spawn,stilts_command

set_plot,'x'


web_cme,planet_all,spacecraft_all,file_out=path_out+'index.html'


end

pro prop_end,planets_str=planets_str,spacecraft_str=spacecraft_str,t0=t0,x0=x0,width=width,vel=vel,e_vel=e_vel,PATH_OUT=PATH_OUT

if ~keyword_set(t0) then t0 = anytim(systim(),/ccs) else t0=anytim(t0,/ccs)
if (n_elements(x0) eq 0) then x0=[0]; lon-lat HGI
if (n_elements(width) eq 0) then width=45 ; width in deg
if ~keyword_set(vel) then vel=800 ;km/s
if ~keyword_set(e_vel) then e_vel=0 ;km/s
if ~keyword_set(path_out) then path_out = '/tmp/'

planet_name = ['MERCURY','VENUS','EARTH','MARS','JUPITER','SATURN','URANUS','NEPTUNE','PLUTO']
;===================================================================
;====================  Obtain properties of planets and spacecraft if they are not input.
if data_chk(planets_str,/type) ne 8 then ellip = planet_orbit(t0,3,planet=earth,all_planets=planets_str)
if data_chk(spacecraft_str,/type) ne 8 then spacecraft_str  = spacecraft_path(t0,drange=300)

x_sol = [x0,0]
cme_prop_sp,planets_str=planets_str,spacecraft_str=spacecraft_str,x_sol=x_sol,t_sol=t0,cme_vel=vel,dlong=width,cme_val=cme_all,e_vel=e_vel

ploting_prop,planets_str,spacecraft_str,path_out,/plot_cme,cme_val=cme_all,cme_s=[long_hgihg(x_sol[0],/hg,date=t0),width]

writing_prop_out,planets_str,spacecraft_str,path_out,x0,t0,width,vel,e_vel

end
