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
@./planet_orbit.pro
pro ploting_swprop, swres ,file_out

	inner_r = [-2.5,2.5]
	outer_r = [-46.5,46.5]
	
	planets_colors=[9,7,5,3,6,2,4,10,9]
	
	set_plot,'z'
	loadct,0,/silent
	COMBINE_COLORS,/LOWER	
	loadct,5,/silent
	COMBINE_COLORS
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
	
	; Plot the planets on both times, with fill and not.
	;loadct,0,/silent
	plot,xsol,ysol,psym=3,xrange=inner_r,yrange=inner_r,xstyle=5,ystyle=5,position=position
	
	;orbits
	for i = 0,3 do begin
	   planprams = planet_orbit(swres[i+1].starttim,i+1, planet=plan)
	   pp=plot_orbit(plan,/orbit,/over,color=100,thick=5)
	endfor
	;planets
	;set_line_color
	
	circle_sym, thick = 2
	for i = 0,3  do begin
	   jd_struct = anytim2jd(swres[i+1].starttim)
       jd_date = jd_struct.int + jd_struct.frac
       ; Conv to HGI
       year = (strsplit(anytim(swres[i+1].starttim,/ecs),'/',/extract))[0]
       long_asc_node = 74+(22.+((year-1900)*.84))/60.
  
       ; Planet Start Position
       helio, jd_date, i+1, hel_radi, hel_loni, hel_lati
       hel_loni-=long_asc_node 
	   polrec, hel_radi, hel_loni, px, py, /deg
	   plots, px, py ,psym=8,color=planets_colors[i],symsize=syms
	endfor
	circle_sym, thick = 2,/fill
	
	for i = 0,3  do begin
	   jd_struct = anytim2jd(swres[i+1].HITIM)
       jd_date = jd_struct.int + jd_struct.frac
       ; Conv to HGI
       year = (strsplit(anytim(swres[i+1].HITIM,/ecs),'/',/extract))[0]
       long_asc_node = 74+(22.+((year-1900)*.84))/60.
  
       ; Planet Final Position
       helio, jd_date, i+1, hel_radi, hel_loni, hel_lati
       hel_loni-=long_asc_node 

print,hel_loni,swres[i+1].lon_hgi,swres[i+1].lon_hg

	   polrec, hel_radi, hel_loni, px, py, /deg
	   plots, px, py, psym=8,color=planets_colors[i],symsize=syms
	endfor
	;Plot the sun
	plots, [ 0 , 0 ], [ 0, 0 ], psym = 8, color = 2, symsize = syms+1
	
	;Legend of planets
	plots,0.1,0.1,/normal,psym = 8, color = 2, symsize = syms
	xyouts, 0.13,0.09, 'Sun',color=0,/normal,Font=ff, Charsize=cs
	circle_sym, thick = 2
	plots,0.3,0.1,/normal,psym = 8, color = 0, symsize = syms
	xyouts, 0.33,0.09, 'Start Time',color=0,/normal,Font=ff, Charsize=cs
	circle_sym, thick = 2,/fill
	plots,0.5,0.1,/normal,psym = 8, color = 0, symsize = syms
	xyouts, 0.53,0.09, 'End Time',color=0,/normal,Font=ff, Charsize=cs
	plots,0.1,0.05,/normal,psym = 8, color = planets_colors[0], symsize = syms
	xyouts, 0.13,0.04, 'Mercury',color=0,/normal,Font=ff, Charsize=cs
	plots,0.3,0.05,/normal,psym = 8, color = planets_colors[1], symsize = syms
	xyouts, 0.33,0.04, 'Venus',color=0,/normal,Font=ff, Charsize=cs
	plots,0.5,0.05,/normal,psym = 8, color = planets_colors[2], symsize = syms
	xyouts, 0.53,0.04, 'Earth',color=0,/normal,Font=ff, Charsize=cs
	plots,0.7,0.05,/normal,psym = 8, color = planets_colors[3], symsize = syms
	xyouts, 0.73,0.04, 'Mars',color=0,/normal,Font=ff, Charsize=cs
	
	
	background = TVREAD(TRUE=3)

    ;** imagemagick way
    ;a = rebin(transpose(foreground,[2,0,1]),3,600,600)
    ;write_png,file_out+'_inner_fg.png',a
    a = rebin( transpose(background,[2,0,1]),3,600,600)
    write_png,file_out+'_inner.png',a
    ;spawn,'convert '+file_out+'_inner_bg.png -fuzz 05% -transparent white '+file_out+'_inner_bg_tr.png'
    ;spawn,'convert '+file_out+'_inner_fg.png -fuzz 05% -transparent white '+file_out+'_inner_fg_tr.png'
    ;spawn,'composite -dissolve 100 -gravity center '+ file_out+'_inner_bg_tr.png '+file_out+'_inner_fg_tr.png '+file_out+'_inner_b.png'
    ;spawn,'convert '+file_out+'_inner_b.png -background white -flatten '+file_out+'_inner.png'
    ;spawn,'rm '+file_out+'_inner_[fg,bg,b]*.png'
    
;    set_plot,'x'
;    set_plot,'z'
    
    ; Plot the planets on both times, with fill and not.
	;loadct,0,/silent
	plot,xsol,ysol,psym=3,xrange=outer_r,yrange=outer_r,xstyle=5,ystyle=5,position=position
	
	;orbits
	for i = 4,8 do begin
	   planprams = planet_orbit(swres[i+1].starttim,i+1, planet=plan)
	   pp=plot_orbit(plan,/orbit,/over,color=100,thick=5)
	endfor
	;planets
	;set_line_color
	circle_sym, thick = 2
	for i = 4,8  do begin
	   jd_struct = anytim2jd(swres[i+1].starttim)
       jd_date = jd_struct.int + jd_struct.frac

       ; Conv to HGI
       year = (strsplit(anytim(swres[i+1].starttim,/ecs),'/',/extract))[0]
       long_asc_node = 74+(22.+((year-1900)*.84))/60.
  
       ; Planet Start Position
       helio, jd_date, i+1, hel_radi, hel_loni, hel_lati
       hel_loni-=long_asc_node 
	   polrec, hel_radi, hel_loni, px, py, /deg
	   plots, px, py ,psym=8,color=planets_colors[i],symsize=syms
	endfor
	circle_sym, thick = 2,/fill
	for i = 4,8  do begin
	   jd_struct = anytim2jd(swres[i+1].HITIM)
       jd_date = jd_struct.int + jd_struct.frac

       ; Conv to HGI
       year = (strsplit(anytim(swres[i+1].HITIM,/ecs),'/',/extract))[0]
       long_asc_node = 74+(22.+((year-1900)*.84))/60.
  
       ; Planet Start Position
       helio, jd_date, i+1, hel_radi, hel_loni, hel_lati
       hel_loni-=long_asc_node 
	   polrec, hel_radi, hel_loni, px, py, /deg
	   plots, px, py, psym=8,color=planets_colors[i],symsize=syms
	   plots, px, py, psym=8,color=planets_colors[i],symsize=syms
	endfor
	;Plot the sun
	 plots, [ 0 , 0 ], [ 0, 0 ], psym = 8, color = 2, symsize = syms+1
	
	;Legend of planets
	plots,0.1,0.1,/normal,psym = 8, color = 2, symsize = syms
	xyouts, 0.13,0.09, 'Sun',color=0,/normal,Font=ff, Charsize=cs
	circle_sym, thick = 2
	plots,0.3,0.1,/normal,psym = 8, color = 0, symsize = syms
	xyouts, 0.33,0.09, 'Start Time',color=0,/normal,Font=ff, Charsize=cs
	circle_sym, thick = 2,/fill
	plots,0.5,0.1,/normal,psym = 8, color = 0, symsize = syms
	xyouts, 0.53,0.09, 'End Time',color=0,/normal,Font=ff, Charsize=cs
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
	
	
	background = TVREAD(TRUE=3)
	
	;** imagemagick way
	;a = rebin(transpose(foreground,[2,0,1]),3,600,600)
	;write_png,file_out+'_outer_fg.png',a
	a = rebin( transpose(background,[2,0,1]),3,600,600)
	write_png,file_out+'_outer.png',a
	;spawn,'convert '+file_out+'_outer_bg.png -fuzz 05% -transparent white '+file_out+'_outer_bg_tr.png'
	;spawn,'convert '+file_out+'_outer_fg.png -fuzz 05% -transparent white '+file_out+'_outer_fg_tr.png'
	;spawn,'composite -dissolve 100 -gravity center '+ file_out+'_outer_bg_tr.png '+file_out+'_outer_fg_tr.png '+file_out+'_outer_b.png'
	;spawn,'convert '+file_out+'_outer_b.png -background white -flatten '+file_out+'_outer.png'
	;spawn,'rm '+file_out+'_outer_[fg,bg,b]*.png'

end


pro web_sw,planets,input,file_out=file_out
planet_name = ['MERCURY','VENUS','EARTH','MARS','JUPITER','SATURN','URANUS','NEPTUNE','PLUTO']

file_input = file_out+'_input_'
file_output = file_out+'_output_'
file_cxs = file_out+'_cxs_'

openw,lun,file_input,/get_lun
  printf,lun,"<li> Start Time <div class='input'>"+anytim(input.time,/ccs)+"</div></li>"
  printf,lun,"<li> Longitude <div class='input'>"+string(input.long,format='(F6.2)')+"</div></li>"
  printf,lun,"<li> SolarWind speed <div class='input'>"+string(input.vel,format='(F0.2)') +"</div></li>"
  printf,lun,"<li> <a href='http://cagnode58.cs.tcd.ie:8080/PropagationModelGUI/'><button type='button'>Reset</button></a></div></li>"
  printf,lun,"</ul> </div>  <!-- input values -->"
;  printf,lun,"</div><!-- input box -->"
close,/all

openw,lun,file_output,/get_lun
  printf,lun,"	<div class='Result'> <!-- result box -->"
  hits = where(planets.hitormiss eq 1,nhits)
  if nhits eq 0 then begin
     printf,lun," <ul> <li> No Planet is hit </li></ul>"
  endif else begin
     printf,lun," <ul> <li> Output </li></ul>" 
     printf,lun,"    <table>" 
     printf,lun,"     <tr> <th> Planet </th> <th> ETA </th> <th> Dt(days) </th></tr>"
     for i=0,nhits-1 do begin
        printf,lun,"     <tr> <td>"+planets[hits[i]].planet+"</td><td>"+$
                                   planets[hits[i]].HITIM+"</td><td align='center'>"+$
                                   string(planets[hits[i]].tdiff,format='(F6.2)')+$
                   "</td></tr>"
     endfor
     printf,lun,"    </table>" 
     printf,lun,"<div class='download'><a href='./sw_pm.votable'><button type='button'>Download VOTable</button></a></div>"
  endelse
  printf,lun,"   </div> <!-- result box -->"
close,/all

openw,lun,file_cxs ,/get_lun
  printf,lun,"		<div class='links'> <!-- links box -->"
  printf,lun,"	  <ul>"
  date=strsplit(anytim(input.time,/ecs,/date),'/',/extract)
  date0=strsplit(anytim(anytim(input.time)-(24*3600.),/ecs,/date),'/',/extract)
  date1=strsplit(anytim(anytim(input.time)+(24*3600.),/ecs,/date),'/',/extract)
  link_goes = "http://helio-vo.eu/services/interfaces/helio-cxs_soap2.php?y_from="+date0[0]+"&mo_from="+date0[1]+"&d_from="+date0[2]+"&h_from=00&mi_from=00&s_from=00&y_to="+date1[0]+"&mo_to="+date1[1]+"&d_to="+date1[2]+"&h_to=23&mi_to=59&s_to=59&cxs_process=goesplotter&format=html"
  printf,lun,"      <li> <a href='"+link_goes+"'> GOES plotter</a></li>"
  link_flares = "http://helio-vo.eu/services/interfaces/helio-cxs_soap2.php?y_from="+date0[0]+"&mo_from="+date0[1]+"&d_from="+date0[2]+"&h_from=20&mi_from=00&s_from=00&y_to="+date1[0]+"&mo_to="+date1[1]+"&d_to="+date1[2]+"&h_to=23&mi_to=59&s_to=59&cxs_process=flareplotter&format=html"
  printf,lun,"      <li> <a href='"+link_flares+"'> Flare plotter</a></li>"
  
  sm_link = "http://solarmonitor.org/index.php?date="+date[0]+date[1]+date[2]
  printf,lun,"      <li> <a href='"+sm_link+"'> Solar Monitor for "+anytim(input.time,/vms,/date)+"</a></li>"

  sw_link = "http://spaceweather.com/archive.php?view=1&day="+date[2]+"&month="+date[1]+"&year="+date[0]
  printf,lun,"      <li> <a href='"+sw_link+"'> Space Weather for "+anytim(input.time,/vms,/date)+"</a></li>"

  printf,lun," </ul>"
close,/all

;spawn cat header .... footer > file_out
join_all = 'cat sw_index_header.html '+file_input+' '+file_output+' '+file_cxs +' sw_index_footer.html > '+ file_out
spawn,join_all

;spawn delete midfiles
delete_midfiles = 'rm '+file_input+' '+file_output+' '+file_cxs 
spawn,delete_midfiles
end







pro prop_sw,t0=t0,x0=x0,swvel=swvel, plot=plot, PATH_OUT = PATH_OUT
; The in put should be a date time string eg 2008-10-12T00:44
; x0 the HG long of the ch on th sun, 15.0 and swvel the solar wind
; velocity in km/s

   rs = 6.9559d8   ; meters
   au = 215.0d*rs  ; rsuns
   ra2deg = 180.0d/!dpi 
   deg2ra = 1.0d/ra2deg
   
   if ~keyword_set(t0) then t0 = anytim(systim(),/ccs) else t0=anytim(t0,/ccs) 
   x0 = (~keyword_set(x0)) ? 0.0d : x0; lon-lat HGI
   if ~keyword_set(swvel) then swvel=400d3 ;km/s
   if ~keyword_set(path_out) then path_out = '/tmp/'
   x0_hg=x0
   x0 = long_hgihg(x0, /hg, date='2008-06-14T00:00')
   x1=x0
   swvel1=swvel
   
   planet_name = ['','MERCURY','VENUS','EARTH','MARS','JUPITER','SATURN','URANUS','NEPTUNE','PLUTO']
    
   ;start time; long_hgi; long_hg; swspeed; planet; hitormiss;date_hit; days-difference
   resstr={starttim:'', lon_hgi:0.0d, lon_hg:0.0d, swspeed:0.0d, planet:'', hitormiss:0, hitim:'', tdiff:0.0d}

   fin=[resstr]
   for i=1,9 do begin
      x1=x0
      swvel1=swvel
	  sw_prop, planetn=i,t0=t0,long0=x1, sw_vel=swvel1, res=pres
      resstr={starttim:t0, $
               lon_hgi:pres.lon_hgi, $ 
               lon_hg:long_hgihg(pres.lon_hgi, /ihg, date=t0), $
               swspeed:swvel1, $
               planet:planet_name[i], $
               hitormiss:1, $
               hitim:pres.hitim, $
               tdiff:pres.tdiff}
      fin=[fin, resstr]
   endfor
   
   ploting_swprop, fin, path_out+'sw_pm'
   
   if keyword_set(plot) then begin
      !p.multi=[0,1,2]
      ; Inner 1-3
      plot, [0, 0], [0, 0], /nodata, xtit='X (AU)', ytit='Y (AU)', xr=[-1.2, 1.2], yr=[-1.2, 1.2], /xs,/ys, /iso, tit='Inner Solar System'
      circle_sym, /fill
      plots, 0, 0, psym=8, syms=3, color=2
      
      ; Solar rotation, synodic period of 26.24 from  http://en.wikipedia.org/wiki/Solar_rotation
      tperiod_sun = 26.24d
      omega_sun = (!dpi*2.0d) / (tperiod_sun*60.0d*60.0d*24.0d) ; radian/sec
      
      rr = linspc(0, 1.2, 1000)
      tht = (omega_sun/swvel)*rr*au+x0
      oplot, rr, tht, /polar
      
      for i =1, 3 do begin
            ; Time
            jd_struct = anytim2jd(times[i])
            jd_date = jd_struct.int + jd_struct.frac
            
            ; Conv to HGI
            year = (strsplit(anytim(t0,/ecs),'/',/extract))[0]
            long_asc_node = 74+(22.+((year-1900)*.84))/60.

            ; Planet Position
            helio, jd_date, i, hel_radi, hel_loni, hel_lati
            hel_loni-=long_asc_node
            polrec,hel_radi, hel_loni,px,py,/degrees
      
      		plots, px, py, psym=4, color=i
      		xyouts, px, py, times[i]
      endfor
      
      ; Outter 4-8
      plot, [0, 0], [0, 0], /nodata, xtit='X (AU)', ytit='Y (AU)', xr=[-50, 50], yr=[-50, 50], /xs,/ys,/iso, tit='Outter Solar System'
      plots, 0, 0, psym=8, syms=1, color=2
      
      rr = linspc(0, 50, 1000)
      tht = (omega_sun/swvel)*rr*au+x0
      oplot, rr, tht, /polar
      
      for i =4, 8 do begin
            ; Time
            jd_struct = anytim2jd(times[i])
            jd_date = jd_struct.int + jd_struct.frac

            ; Conv to HGI
            year = (strsplit(anytim(t0,/ecs),'/',/extract))[0]
            long_asc_node = 74+(22.+((year-1900)*.84))/60.

            ; Planet Position
            helio, jd_date, i, hel_radi, hel_loni, hel_lati
            hel_loni-=long_asc_node
            polrec,hel_radi, hel_loni,px,py,/degrees
      
      		plots, px, py, psym=4, color=i
      		xyouts, px, py, times[i]
      endfor
   endif
   
   ;writing out the info
   file_out = path_out + 'sw_pm'
   openw,lun,file_out+'.out',/get_lun
   printf,lun,"#Starting parameters"
   printf,lun,'Starting time: '+t0
   printf,lun,'Starting longitude (HGI): '+string(x0,format='(D0.2)')
   printf,lun,'Starting longitude (HG): '+string(x0_hg,format='(D0.2)')
   ;printf,lun,'Width: '+string(width,format='(F6.2)')
   printf,lun,'Solar Wind Velocity: '+string(swvel,format='(F0.2)')
   for i=1,9 do begin
	   printf,lun,'------------------------------'
	   printf,lun,'planet:'+string(fin[i].planet)
	   ;printf,lun,'distance:'+string(planet_all[i].start.radio,format='(F7.3)')
	   printf, lun, 'Long HI:'+string(fin[i].lon_hg, format='(F6.2)')
	   printf, lun, 'Long HGi:'+string(fin[i].lon_hgi, format='(F6.2)')
	   printf,lun,'hit:'+ string(fin[i].hitormiss,format='(I1)')
	   printf, lun, 'T Diff:'+string(fin[i].tdiff, format='(F6.2)')
	   ;t1_out = (planet_all[i].hitormiss eq 0)?'0':planet_all[i].hitpos.date
	   printf,lun,'ETA:'+fin[i].HITIM
   endfor
   close,/all
   file_out=path_out+'sw_pm'
   openw,lun,file_out+'.csv',/get_lun
   printf,lun,"time_start,long_hg,long_hci,vsw,target_obj,target_long_hg, target_long_hci, HitOrMiss,Dt,ETA"
   start_str = t0 + ',' + $
            string(x0_hg,format='(F6.2)') +',' + $
            string(x0, '(F6.2)') +',' + $
            string(swvel,format='(F0.2)')
   for i = 1,9  do begin
	   ;t1_out = (p[i].hitormiss eq 0)?'':planet_all[i].hitpos.date
	   ;t1_out_min = (t1_out eq '')?'':planet_all[i].minmax_t.t_min
	   ;t1_out_max = (t1_out eq '')?'':planet_all[i].minmax_t.t_max
	   ;dt1_out = (t1_out eq '')?'':string((anytim(planet_all[i].hitpos.date) - anytim(t0))/(3600.*24.),format='(F7.3)')
	   ;dt1_out_min = (t1_out eq '')?'':string((anytim(planet_all[i].minmax_t.t_min) - anytim(t0))/(3600.*24.),format='(F7.3)')
	   ;dt1_out_max = (t1_out eq '')?'':string((anytim(planet_all[i].minmax_t.t_max) - anytim(t0))/(3600.*24.),format='(F7.3)')
	
	   rest_str = string(fin[i].planet) + ',' + $ ; Planet
				  string(fin[i].lon_hg, format='(F6.2)') +',' +  $ ; planet long hg
				  string(fin[i].lon_hgi, format='(F6.2)') +',' +  $ ; planet long hgi
				  string(fin[i].hitormiss,format='(I1)') +',' +  $ ; HitOrMiss
				  string(fin[i].tdiff, format='(F6.2)') +',' + $    ; Time diff days
				  fin[i].HITIM                                        ; ETA
	
	   printf,lun,start_str+','+rest_str
   endfor
   close,/all   
stilts_command = './stilts tcopy '+file_out+'.csv ifmt=csv '+file_out+'.votable ofmt=votable'
spawn,stilts_command

input = {time:t0,long:x0_hg,vel:swvel}
web_sw,fin,input,file_out=path_out+'index.html'

end
