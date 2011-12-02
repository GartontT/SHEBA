function distance,x1,x2,y1,y2
  d=sqrt(abs(x1-x2)^2.+abs(y1-y2)^2.)
return,d
end

pro measuring_spiral,date,vel_wind=vel_wind,plot=plot
;-
; measuring_spiral
;
;  Optional Inputs: DATE in any standard format. e.g. '13-june-2011'
;                   VEL_WIND velocity of the solar wind in km/s, default 400km/s
;                   /plot if plot wanted
;+



  if ( n_elements( date ) eq 0 ) then get_utc, date, /vms
  if ( n_elements( vel_wind ) eq 0 ) then vel_wind=400

; Convert date to Julian date
  jd_struct = anytim2jd( date )
  jd = jd_struct.int + jd_struct.frac
 
; Calculate earth heliocentric latitude, longitude and distance from Sun
  helio, jd, 3, hel_rad, hel_lon, hel_lat

  vel_wind_au = ( vel_wind / 150e6 ) * 24. * 60. * 60. ; AU per day
  rot_sun =  14.4 ; rotation rate of the Sun in degrees per day
  theta_spiral = -findgen( 3000)/1000.*hel_lon
  r_spiral = -( vel_wind_au / rot_sun ) * theta_spiral

; Calculate line that pass through earth
   earth_lon=hel_lon
   dumb=min(abs(r_spiral-hel_rad),ll)
   foot_point_planet=abs(theta_spiral[ll])                  ;abs(theta_spiral[ll]-hel_lon)
   dist_SEspiral = 0
  polrec, r_spiral, theta_spiral, pos_x, pos_y, /degrees
   for dd=0,ll-1 do begin
      dist_portion=distance(pos_x[dd+1],pos_x[dd],pos_y[dd+1],pos_y[dd])
      dist_SEspiral=dist_portion+dist_SEspiral
   endfor
   print,'foot-point connected with Earth:',string(foot_point_planet,format='(F7.2)'),' @ ',string(vel_wind,format='(I3)'),'km/s Total distance Spiral: ',dist_seSPIRAL,' AU = ',dist_SEspiral*150e6,' km = ',dist_SEspiral*150e6/(1.392e6/2.) , ' Ro' ;,format='(F7.5)');,earth_lon,theta_spiral[ll]

if keyword_set(plot) then begin
   
;Ploting
   set_line_color
   planet_nos = indgen(9)
   helio, jd, planet_nos, hel_rad, hel_lon, hel_lat
   polrec, hel_rad, hel_lon, pos_x, pos_y, /degrees
   plot, pos_x, pos_y, psym = 3,$
         xtitle = 'Heliocentric Distance (AU)', ytitle = 'Heliocentric Distance (AU)', $
         title = strmid( date, 0, 11 ) + ' (' + arr2str( vel_wind, /trim ) + ' km/sec)',xrange=[-2,2],yrange=[-2,2], /ystyle, /xstyle
   circle_sym, thick = 2, /fill
   for i=1,8 do  plots, pos_x[i], pos_y[i], psym = 8, color = i, symsize = 2
   

   
   polrec, r_spiral, ( theta_spiral+earth_lon)+ foot_point_planet, spir_x, spir_y, /degrees
   oplot, spir_x, spir_y, color = 5, thick = 2
   
; Finally plot   the Sun!
   plots, [ 0 , 0 ], [ 0, 0 ], psym = 8, color = 2, symsize = 3
   xyouts, 0, 0-0.1, 'Sun', align = 0.5, /data
   
endif
   
end

