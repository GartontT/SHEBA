PRO cme2csv, cme_str, t0, path_out
  ;+
  ;CME2CSV generates a file to be used for Solarbrowser
  ;
  ;-

  ; Calculate per every 2 hours time and distance
  cme_days = findgen(12. * max(cme_str.cme_t))/12. ; 12 points per day
  cme_radius = interpol(cme_str.cme_r,cme_str.cme_t,cme_days)


  file_out = path_out+'cme_pm_solarbrowser'
  openw,lun,path_out+'.csv',/get_lun

  ; Write out starting time, lon and width in the comments
  printf, lun, '# starting time [iso]: ' + t0
  printf, lun, '# Longitude CME [degrees]: ' + string(cme_str.lon, format='(F6.2)')
  printf, lun, '# Width CME [degrees]: ' + string(cme_str.width, format='(F6.2)')
  printf, lun, '# Time [days] from starting time, Radius [AU] from Sun center'
  ; Write out cme iso time and radius as CSV
  for j=0, n_elements(cme_radius)-1 do begin
     printf, lun, cme_days[j] + ',' + cme_radius[j]
  endfor
  close, /all

  



END
