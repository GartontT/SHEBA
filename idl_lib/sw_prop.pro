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
pro sw_prop, planetn=planetn,t0=t0,long0=long0, sw_vel=sw_vel, res=res, plot=plot, test=test
	
	; Constants and conversions
	rs = 6.9559d8   ; meters
	au = 215.0d*rs  ; rsuns
	ra2deg = 180.0d/!dpi 
    deg2ra = 1.0d/ra2deg
    
   ; Check for keywords and set defaults
   if ~keyword_set(planetn) then planetn=3
   if ~keyword_set(t0) then t0 = anytim(systim(),/ccs) else t0=anytim(t0,/ccs)
   long0 = (~keyword_set(long0)) ? 0.0d : long0; lon-lat HGI
   sw_vel = (~keyword_set(sw_vel)) ?  400d3 : sw_vel*1d3 ;km/s
   
   ; Convert long from hg to hgi
   ;long0 = long_hgihg(long0, /hg, date=t0)
   long0 = long0*deg2ra
   
   ; Iterative code would be better but can get it to work
   ;test = intersect_sprialplanet_iter(t0, long0, sw_vel, planetn, 0.0d, 0.0d ,/plot)

   ; Solar rotation, synodic period of 26.24 from  http://en.wikipedia.org/wiki/Solar_rotation
   tperiod_sun = 26.24d
   omega_sun = (!dpi*2.0d) / (tperiod_sun*60.0d*60.0d*24.0d) ; radian/sec
   
   ; Start time
   jd_struct = anytim2jd(t0)
   jd_date1 = jd_struct.int + jd_struct.frac

   ; Conv to HGI
   year = (strsplit(anytim(t0,/ecs),'/',/extract))[0]
   long_asc_node = 74+(22.+((year-1900)*.84))/60.
  
   ; Planet Start Position
   helio, jd_date1, planetn, hel_radi, hel_loni, hel_lati
   hel_loni-=long_asc_node 
  
   ; Make sure allways positve 0 - 2pi
   neg = where(hel_loni lt 0.0d)
   if neg[0] ne -1 then begin
;      stop
      hel_loni[neg] = 360.0d + hel_loni[neg] 
   endif
   polrec,hel_radi, hel_loni,px,py,/degrees
   
   ; Parker Spiral Start Position
   theta = -1.0d*((omega_sun/sw_vel)*hel_radi*au) + long0
       
   ; Calulate the difference in agngle between plant and spiral (at planet radius)
   deltaang = abs(theta - hel_loni*deg2ra)   ; conv to radians
   deltat = deltaang/omega_sun               ; equvalent time diff at solar eq

   ; Calc min time to get to planet assumeing const vel and current planet pos
   ;min_tim = (hel_radi*au)/sw_vel
   ;print, min_tim/(60.0*60.0*24.0d)
   min_tim=0.0d

   ; Loop over 1 full rotation of the Sun ?? Not sure if this will ALWAYS be suffuicent
   ; Time array
   timadd=0.0d
   exptim:
   
   tgrid = linspc(anytim(t0)+min_tim, anytim(t0)+min_tim+(tperiod_sun*60.0d*60.0d*24.0d)+timadd, 10000)
   jd_struct = anytim2jd(tgrid)
   jd_date2 = jd_struct.int + jd_struct.frac
   
   ; Planet position at times
   helio, jd_date2, planetn, hel_rad, hel_lon, hel_lat
   hel_lon-=long_asc_node
   
   ; Make sure allways positve 0 - 2pi
   neg = where(hel_lon lt 0.0d)
   if neg[0] ne -1 then hel_lon[neg] = 360.0d + hel_lon[neg]
   
   ; Caculate postion of parker spiral at times
   theta = -1.0d*((omega_sun/sw_vel)*hel_rad*au) + long0 + ((tgrid-tgrid[0])+min_tim)*omega_sun  
   
   while min(theta) lt 0.0d do begin &$
      ind = where(theta lt 0.0) &$
      theta[ind] = 2*!dpi + theta[ind] &$
   endwhile &$
   
   ; Make sure theta only goes from 0 to 2 pi same as hel_lon
   while max(theta) gt 2*!dpi do begin
      ind = where(theta gt 2*!dpi)
      theta[ind] = theta[ind] - 2*!dpi
   endwhile 
   
   ; Find point of cloest approach of the two in terms of theta (unique?!?)
   mtch = where(abs(theta - hel_lon* deg2ra) eq min(abs(theta - hel_lon* deg2ra)), cts)
  
   ;plot, (tgrid-tgrid[0])/(60.0*60.0*24.0d), theta
   ;oplot, (tgrid-tgrid[0])/(60.0*60.0*24.0d), hel_lon*deg2ra
  
   dtheta = theta[0:9998]-theta[1:*] 
   if max(dtheta ge !dpi ) then begin 
      mxdiff = where(dtheta eq max(dtheta))
      if mtch ge mxdiff then begin
		  if dtheta[mxdiff] gt dtheta[mxdiff+1] then begin
			  ; 1st half high, 2nd half low
			  t1 = min( (theta[0:mxdiff] ge hel_lon[0:mxdiff]*deg2ra) and (theta[0:mxdiff] le hel_lon[0:mxdiff]*deg2ra) )
			  aa= (theta[mxdiff+1:*] ge hel_lon[mxdiff+1:*]*deg2ra)
			  if (total(aa) eq 0.0 or total(aa) eq n_elements(aa)) then t2=0 else t2=1
			  ;t2 = aa= (theta[mxdiff+1:*] ge hel_lon[mxdiff+1:*]*deg2ra)
			  if ~t1 and ~t2 then begin
				 print, 'Adding Time'
				 timadd=timadd+2.0d*(60.0*60.0*24.0d)
				 goto, exptim
			  endif
		  endif else if dtheta[mxdiff] lt dtheta[mxdiff+1] then begin
			  print, 'Entering Uncharted Territory'
			  ; 1st half high, 2nd half low
			  ;t1 = theta[0:mxdiff] ge hel_lon[0:mxdiff]*deg2ra or theta[0:mxdiff] le hel_lon[0:mxdiff]*deg2ra
			  ;t2 = theta[mxdiff+1:*] ge hel_lon[mxdiff+1:*]*deg2ra or theta[mxdiff+1:*] le hel_lon[mxdiff+1:*]*deg2ra
			  ;if t1 and t2 then begin
			  ;   stop
			  ;   timadd=timadd+2.0d*(60.0*60.0*24.0d)
			  ;   goto, exptim
			  ;endif
		  endif
       endif
    endif
  
  if cts gt 1 then begin
     print, 'Found more than one match :-('
  endif
   
   if keyword_set(test) then begin
       rr=linspc(0, hel_rad[0]*1.4, 1000)
	   thetas = -1.0d*((omega_sun/sw_vel)*rr*au) + long0
	   polrec, hel_rad, hel_lon, pxp, pyp, /deg
	   !p.multi=[0,1,2]
	   plot, /polar, rr, thetas, xr=[-max(rr), max(rr)], yr=[-max(rr), max(rr)], /iso, xtit='X (AU)', ytit='Y (AU)'
	   plots, pxp[0], pyp[0], psym=4
	   for i =1, mtch[0] do begin
	      thts = -1.0d*((omega_sun/sw_vel)*rr*au) + long0 + (tgrid[i]-tgrid[0]+min_tim)*omega_sun
	      oplot, /polar, rr, thts, color=3
	      plots, pxp[i], pyp[i], psym=4, color=3
	   endfor
   endif
   
   ; Print out Results
   ;print, 'Start Time:               '+t0
   ;print, 'Expected Arrival of HSWS: '+anytim(tgrid[mtch], /cc)
   
   tmp = {hitim:anytim(tgrid[mtch], /cc), $
             tdiff:(anytim(tgrid[mtch]) - anytim(t0))/(24.0*60.0*60.0d), $
             lon_hgi:hel_lon[mtch] $
             }
   
   ; Return insection time as keyword
   res = tmp
   
   ;  Plot to see if it look right
   if keyword_set(plot) then begin 
	   rr=linspc(0, hel_radi*au*1.4, 1000)
	   thetas = -1.0d*((omega_sun/sw_vel)*rr) + long0
	   !p.multi=[0,1,2]
	   plot, /polar, rr/au, thetas, xr=[-max(rr/au), max(rr/au)], yr=[-max(rr/au), max(rr/au)], /iso, xtit='X (AU)', ytit='Y (AU)'
	   plots, px, py, psym=4
	   thetas= -1.0d*((omega_sun/sw_vel)*rr) + long0 + ((tgrid[mtch]-tgrid[0])*omega_sun)[0]
	   oplot, rr/au, thetas, color=3,/polar
	   
	   polrec, hel_rad, hel_lon, px, py, /deg
	   plots, px, py, psym=3
	   plots, px[mtch], py[mtch], psym=4, color=3 
	
	   plot, (tgrid-tgrid[0])/(60.0*60.0*24), theta, xtit='Time (Days)', ytit='Planet - Sprial Ang (Radians)', yr=[0, 2*!dpi] ,/xs, /ys
	   oplot, (tgrid-tgrid[0])/(60.0*60.0*24), hel_lon*(!dpi/180.0d), lines=2
	   plots, (tgrid[mtch]-tgrid[0])/(60.0*60.0*24), theta[mtch], psym=4, color=3
	   legend, ['Parker Spiral', 'PLanet'], lines=[0,2],/right
   endif
 
end
