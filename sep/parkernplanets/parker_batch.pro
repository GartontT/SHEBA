pro parker_batch, outfile
  
  outfile = 'test'
  
  !p.charsize = 1.2


  for i = 0, 30 do begin
    
    parkernplanets,anytim('1-jan-2008') + i*24.*60.*60.,/inner, vel = 700
    filename = outfile +'_'+string(i,format='(I3.3)')+'.jpg'
    
    print, filename
    
    ;x2jpeg, filename
    
  endfor
  
  ;jsmovie, outfile + '.html', findfile( outfile + '_*.jpg' )
  
end
