function str_hist, array,uniqstr=uniqstr
  hist=intarr(1)
  hist[0]=1
  uniqstrings=strarr(1)
  uniqstrings[0]=array[0]
  for i=1, n_elements(array)-1 do begin
     idx=where(uniqstrings eq array[i])
     if (idx eq -1) then begin  ; found new string
        uniqstrings=[uniqstrings,array[i]]
        hist=[hist,1]
     endif else begin
        hist[idx]++
     endelse
  endfor

  uniqstr = uniqstrings
  return, hist
end
